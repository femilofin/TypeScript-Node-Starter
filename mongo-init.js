db.createUser({
    user: "test-user",
    pwd: "secret",
    roles: [
        {
            role: "readWrite",
            db: "test-db"
        }
    ]
});
