package com.notes.app;

public class Note {
    private String id;
    private String title;
    private String content;

    private boolean pinned;
    private String folderId;
    private int priority;

    public Note(String id, String title, String content, boolean pinned, String folderId, int priority) {
        this.id = id;
        this.title = title;
        this.content = content;
        this.pinned = pinned;
        this.folderId = folderId;
        this.priority = priority;
    }

    public Note() {}

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public boolean isPinned() { return pinned; }
    public void setPinned(boolean pinned) { this.pinned = pinned; }

    public String getFolderId() { return folderId; }
    public void setFolderId(String folderId) { this.folderId = folderId; }

    public int getPriority() { return priority; }
    public void setPriority(int priority) { this.priority = priority; }
}
