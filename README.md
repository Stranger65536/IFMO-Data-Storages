Installation
---

1. Configure database

    Tested on Oracle 12c, 3 instances (storage + 2 branches)
    
    1.1 Create or use existing PDB on each DB, create user with privileges enough to create another schemas and access it (simply use dba)
    
    1.2 Create gradle.properties file and write a bunch of properties used by flyway
    
        branch1.password=
        branch1.url=jdbc:oracle:thin:@//<hostname>:<port>/<PDBNAME>
        branch1.user=
        branch2.password=
        branch2.url=jdbc:oracle:thin:@//<hostname>:<port>/<PDBNAME>
        branch2.user=
        storage.password=
        storage.url=jdbc:oracle:thin:@//<hostname>:<port>/<PDBNAME>
        storage.user=
        
    Fill them with the corresponding credentials from step 1.1
    
    1.3 Execute "before_first_build.sh" to allow flyway gradle plugin use Oracle driver for 12c
    
    1.4 Create database links
    
    In order that flyway is responsible for schema manging only, creating and deleting database links is out of its scope of responsibility.
    You have to create them by yourself through SQL console. Sample file with exact link names is presented at cental_links.sql.
    Replace all placeholders with your actual credentials from step 1.1 and execute it manually.
    
2. Run gradle build
    
    If any flyway errors found, check above steps performed correctly.
        
    