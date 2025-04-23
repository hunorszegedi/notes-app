package com.notes.app;

import static spark.Spark.*;
import com.google.gson.Gson;
import com.google.cloud.datastore.*;
import java.util.ArrayList;
import java.util.List;

public class Main {

    private static final String FOLDER_KIND = "Folder";
    //Gson object for JSON parsing
    private static Gson gson = new Gson();

    //connection to Google Cloud Datastore
    private static final Datastore datastore = DatastoreOptions.getDefaultInstance().getService();

    //every note gets in the "Note" Kind
    private static final String KIND = "Note";
    //lika a name for table

    public static void main(String[] args) {
        //default port
        port(8080);

        //example endpoint
        get("/hello", (req, res) -> "Hello from backend!");

        //POST to save a note
        post("/notes", (req, res) -> {
            Note note = gson.fromJson(req.body(), Note.class);

            // alapértékek, ha nem adott meg semmit
            if (note.getFolderId() == null) note.setFolderId("");
            if (note.getPriority() == 0) note.setPriority(0); // pl. 0 = alacsony
            note.setPinned(false); // új jegyzet nem kiemelt

            KeyFactory keyFactory = datastore.newKeyFactory().setKind(KIND);
            FullEntity<IncompleteKey> entity = Entity.newBuilder(keyFactory.newKey())
                    .set("title", note.getTitle())
                    .set("content", note.getContent())
                    .set("pinned", note.isPinned())
                    .set("folderId", note.getFolderId())
                    .set("priority", note.getPriority())
                    .build();

            Entity saved = datastore.add(entity);
            note.setId(String.valueOf(saved.getKey().getId()));

            res.type("application/json");
            return gson.toJson(note);
        });


        //GET to get all notes
        get("/notes", (req, res) -> {
            Query<Entity> query = Query.newEntityQueryBuilder()
                    .setKind(KIND)
                    .build();
            QueryResults<Entity> results = datastore.run(query);
            List<Note> notes = new ArrayList<>();

            //from entity to Java object
            while (results.hasNext()) {
                Entity entity = results.next();
                Note note = new Note(
                        String.valueOf(entity.getKey().getId()),
                        entity.getString("title"),
                        entity.getString("content"),
                        entity.getBoolean("pinned"),
                        entity.getString("folderId"),
                        (int) entity.getLong("priority")
                );
                notes.add(note);
            }
            res.type("application/json");
            return gson.toJson(notes);
        });

        //DELETE to delete a note
        delete("/notes/:id", (req, res) -> {
            KeyFactory keyFactory = datastore.newKeyFactory().setKind(KIND);
            datastore.delete(keyFactory.newKey(Long.parseLong(req.params(":id"))));
            return "Note deleted";
        });
        
        //PUT to update a note
        put("/notes/:id", (req, res) -> {
            Note note = gson.fromJson(req.body(), Note.class);
            KeyFactory keyFactory = datastore.newKeyFactory().setKind(KIND);
            Key key = keyFactory.newKey(Long.parseLong(req.params(":id")));

            Entity entity = Entity.newBuilder(key)
                    .set("title", note.getTitle())
                    .set("content", note.getContent())
                    .set("pinned", note.isPinned())
                    .set("folderId", note.getFolderId() == null ? "" : note.getFolderId())
                    .set("priority", note.getPriority())
                    .build();

            datastore.update(entity);
            note.setId(req.params(":id"));
            res.type("application/json");
            return gson.toJson(note);
        });

        //POST to save a folder
        post("/folders", (req, res) -> {
            Folder folder = gson.fromJson(req.body(), Folder.class);

            KeyFactory keyFactory = datastore.newKeyFactory().setKind(FOLDER_KIND);
            FullEntity<IncompleteKey> entity = Entity.newBuilder(keyFactory.newKey())
                    .set("name", folder.getName())
                    .build();

            Entity savedEntity = datastore.add(entity);
            folder.setId(String.valueOf(savedEntity.getKey().getId()));

            res.type("application/json");
            return gson.toJson(folder);
        });

        //GET to get all folders
        get("/folders", (req, res) -> {
            Query<Entity> query = Query.newEntityQueryBuilder().setKind(FOLDER_KIND).build();
            QueryResults<Entity> results = datastore.run(query);

            List<Folder> folders = new ArrayList<>();
            while (results.hasNext()) {
                Entity entity = results.next();
                Folder folder = new Folder();
                folder.setId(String.valueOf(entity.getKey().getId()));
                folder.setName(entity.getString("name"));
                folders.add(folder);
            }

            res.type("application/json");
            return gson.toJson(folders);
        });

        //DELETE to delete a folder and its notes
        delete("/folders/:id", (req, res) -> {
            long folderId = Long.parseLong(req.params(":id"));

            Query<Entity> noteQuery = Query.newEntityQueryBuilder()
                    .setKind(KIND)
                    .setFilter(StructuredQuery.PropertyFilter.eq("folderId", folderId))
                    .build();

            QueryResults<Entity> notes = datastore.run(noteQuery);
            while (notes.hasNext()) {
                datastore.delete(notes.next().getKey());
            }

            KeyFactory keyFactory = datastore.newKeyFactory().setKind(FOLDER_KIND);
            datastore.delete(keyFactory.newKey(folderId));

            return "Folder and its notes deleted";
        });

        //PUT to update a folder
        put("/folders/:id", (req, res) -> {
            Folder folder = gson.fromJson(req.body(), Folder.class);
            KeyFactory keyFactory = datastore.newKeyFactory().setKind(FOLDER_KIND);
            Key key = keyFactory.newKey(Long.parseLong(req.params(":id")));

            Entity entity = Entity.newBuilder(key)
                    .set("name", folder.getName())
                    .build();

            datastore.update(entity);
            folder.setId(req.params(":id"));
            res.type("application/json");
            return gson.toJson(folder);
        });



    }
}