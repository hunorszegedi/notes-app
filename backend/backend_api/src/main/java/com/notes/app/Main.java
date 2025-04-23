package com.notes.app;

import static spark.Spark.*;
import com.google.gson.Gson;
import com.google.cloud.datastore.*;
import java.util.ArrayList;
import java.util.List;

public class Main {

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
            //from JSON to Java object
            Note note = gson.fromJson(req.body(), Note.class);
            //new Datastore key
            KeyFactory keyFactory = datastore.newKeyFactory().setKind(KIND);
            //making an entity
            FullEntity<IncompleteKey> entity = Entity.newBuilder(keyFactory.newKey())
                    .set("title", note.getTitle())
                    .set("content", note.getContent())
                    .build();
            //save entity
            Entity savedEntity = datastore.add(entity);
            //return the new entity ID
            note.setId(String.valueOf(savedEntity.getKey().getId()));
            //JSON response
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
                        entity.getString("content")
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
                    .build();
            datastore.update(entity);
            note.setId(req.params(":id"));
            res.type("application/json");
            return gson.toJson(note);
        });
    }
}