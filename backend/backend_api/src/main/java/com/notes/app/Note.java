package com.notes.app;

public class Note {
    private String id;
    private String title;
    private String content;

    //contructor
    public Note(String id, String title, String content) {
        this.id = id;
        this.title = title;
        this.content = content;
    }

    //empty contructor for JSON parsing (Gson)
    public Note() {}

    public String getId() {
        return id;
    }
    public void setId(String id) {
        this.id = id;
    }
    public String getTitle() {
        return title;
    }
    public void setTitle(String title) {
        this.title = title;
    }
    public String getContent() {
        return content;
    }
    public void setContent(String content) {
        this.content = content;
    }

    @Override
    public String toString() {
        return "Note{" + "id=" + id + ", title=" + title + ", content=" + content + '}';
    }



}
