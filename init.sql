
/*
    File: init.sql
    Purpose: This script initializes the database schema for a Kanban management application.
    Structure:
      - Tables: Projects, ProjectColumns, Cards, Tags, CardsTags
      - Procedures: add_card, add_column, pop_card_reorder, pop_column_reorder, update_card, update_column_data, update_project_data
    Usage: Run this script to set up the database schema and stored procedures.
*/

CREATE TABLE Projects (
    id varchar(50) NOT NULL,
    name varchar(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by VARCHAR(50) NOT NULL,
    updated_by VARCHAR(50) NOT NULL,
    PRIMARY KEY (id)
);
CREATE TABLE ProjectColumns (
    id VARCHAR(50) NOT NULL,
    project_id VARCHAR(50) NOT NULL,
    name varchar(50) NOT NULL,
    draw_order INT UNSIGNED NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by VARCHAR(50) NOT NULL,
    updated_by VARCHAR(50) NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (project_id) REFERENCES Projects (id) ON DELETE CASCADE
);
CREATE TABLE Cards (
    id VARCHAR(50) not null,
    column_id VARCHAR(50) not null,
    name VARCHAR(50) not null,
    description TEXT not null,
    draw_order INT UNSIGNED NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by VARCHAR(50) not null,
    updated_by varchar(50) not null,
    PRIMARY KEY (id),
    FOREIGN KEY (column_id) REFERENCES ProjectColumns (id) ON DELETE CASCADE
);
CREATE TABLE Tags (
    id VARCHAR(50) not null,
    project_id VARCHAR(50) not null,
    name VARCHAR(50) not null,
    color VARCHAR(7) not null CHECK (color REGEXP '^#[0-9A-Fa-f]{6}$'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by VARCHAR(50) not null,
    updated_by VARCHAR(50) not null,
    PRIMARY KEY (id),
    FOREIGN KEY (project_id) REFERENCES Projects (id) ON DELETE CASCADE,
    UNIQUE (project_id, name)
);
CREATE TABLE CardsTags (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    card_id VARCHAR(50) NOT NULL,
    tag_id VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    FOREIGN KEY (card_id) REFERENCES Cards (id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES Tags (id) ON DELETE CASCADE
);


CREATE TABLE CardUpdateRecords (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    card_id VARCHAR(50) NOT NULL,
    added TEXT NOT NULL,
    deleted TEXT NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    FOREIGN KEY (card_id) REFERENCES Cards (id) ON DELETE CASCADE 
);


/* Procedures */
DELIMITER $$


CREATE PROCEDURE create_project(
    p_id CHAR(50), 
    p_name CHAR(50),
    p_created_by CHAR(50))
BEGIN
    INSERT INTO Projects (id, name, created_by, updated_by)
    VALUES (
        p_id,
        p_name,
        p_created_by,
        p_created_by
    ); 
END$$


CREATE PROCEDURE create_tag(
    p_project_id CHAR(50), 
    p_id CHAR(50), 
    p_name CHAR(50),
    p_color CHAR(7),
    p_created_by CHAR(50))
BEGIN
    INSERT INTO Tags (project_id, id, name, color, created_by, updated_by)
    VALUES (
        p_project_id,
        p_id,
        p_name,
        p_color,
        p_created_by,
        p_created_by
    ); 
END$$


CREATE PROCEDURE create_card(
    p_column_id CHAR(50), 
    p_id CHAR(50), 
    p_name CHAR(50), 
    p_description TEXT, 
    p_draw_order INT,
    p_created_by CHAR(50))
BEGIN
    INSERT Cards (
        id,
        column_id,
        name,
        description,
        draw_order,
        created_by,
        updated_by
    ) VALUES (
        p_id,
        p_column_id,
        p_name,
        p_description,
        p_draw_order,
        p_created_by,
        p_created_by
    );
END$$


CREATE PROCEDURE create_column(
    p_project_id char(50), 
    p_id char(50), 
    p_name char(50),
    p_draw_order INT,
    p_created_by CHAR(50))
BEGIN
    INSERT ProjectColumns (
        id,
        project_id,
        name,
        created_by,
        updated_by,
        draw_order
    ) VALUES (
        p_id, 
        p_project_id, 
        p_name,
        p_created_by,
        p_created_by,
        p_draw_order
    );
END$$


CREATE PROCEDURE pop_card_reorder(
    p_column_id CHAR(50), 
    p_popped_order INT)
BEGIN
    UPDATE Cards 
    SET 
    draw_order = draw_order - 1
    WHERE draw_order > p_popped_order AND column_id = p_column_id;
END$$


CREATE PROCEDURE pop_column_reorder(
    p_project_id CHAR(50), 
    p_popped_order INT)
BEGIN
    UPDATE ProjectColumns 
    SET 
    draw_order = draw_order - 1
    WHERE draw_order > p_popped_order AND project_id = p_project_id;
END$$


CREATE PROCEDURE update_card(
    p_id CHAR(50), 
    p_column_id CHAR(50), 
    p_name CHAR(50), 
    p_description TEXT,
    p_updated_by CHAR(50),
    p_draw_order INT)
BEGIN
    UPDATE Cards 
    SET 
    name = p_name,
    description = p_description,
    draw_order = p_draw_order,
    column_id = p_column_id,
    updated_by = p_updated_by
    WHERE id = p_id;
END$$


CREATE PROCEDURE update_column_data(
    p_id CHAR(50), 
    p_name CHAR(50), 
    p_updated_by CHAR(50),
    p_draw_order INT)
BEGIN
    UPDATE ProjectColumns 
    SET 
    name = p_name,
    draw_order = p_draw_order,
    updated_by = p_updated_by
    WHERE id = p_id;
END$$


CREATE PROCEDURE update_project_data(
    p_id CHAR(50), 
    p_name CHAR(50),
    p_updated_by CHAR(50))
BEGIN
    UPDATE Projects 
    SET 
    name = p_name,
    updated_by = p_updated_by
    WHERE id = p_id;
END$$


CREATE PROCEDURE read_project(
    p_id CHAR(50)
    )
BEGIN
    SELECT 
        id, 
        name, 
        UNIX_TIMESTAMP(created_at) as 'created_at', 
        UNIX_TIMESTAMP(updated_at) as 'updated_at',
        created_by,
        updated_by
    FROM Projects 
    WHERE id = p_id; 
END$$


CREATE PROCEDURE read_columns_by_project_id(
    p_id CHAR(50)
    )
BEGIN
    SELECT 
        id,
        project_id,
        draw_order,
        name, 
        UNIX_TIMESTAMP(created_at) as 'created_at', 
        UNIX_TIMESTAMP(updated_at) as 'updated_at',
        created_by,
        updated_by
    FROM ProjectColumns
    WHERE project_id = p_id; 
END$$


CREATE PROCEDURE read_column_by_id(
    p_id CHAR(50)
    )
BEGIN
    SELECT 
        id,
        project_id,
        draw_order,
        name, 
        UNIX_TIMESTAMP(created_at) as 'created_at', 
        UNIX_TIMESTAMP(updated_at) as 'updated_at',
        created_by,
        updated_by
    FROM ProjectColumns
    WHERE id = p_id; 
END$$


CREATE PROCEDURE read_tags_by_project_id(
    p_project_id CHAR(50)
    )
BEGIN
    SELECT 
        id,
        project_id,
        name, 
        color,
        UNIX_TIMESTAMP(created_at) AS 'created_at', 
        UNIX_TIMESTAMP(updated_at) AS 'updated_at',
        created_by,
        updated_by
    FROM Tags
    WHERE project_id = p_project_id; 
END$$


CREATE PROCEDURE read_tags_by_card_id(
    p_card_id CHAR(50)
    )
BEGIN
    SELECT 
        t.id,
        t.project_id,
        t.name, 
        t.color,
        UNIX_TIMESTAMP(t.created_at) AS 'created_at', 
        UNIX_TIMESTAMP(t.updated_at) AS 'updated_at',
        t.created_by,
        t.updated_by
    FROM Tags AS t 
    INNER JOIN CardsTags as ct
    ON ct.tag_id =t.id
    WHERE ct.card_id = p_card_id; 
END$$


CREATE PROCEDURE read_cards_by_column_id(
    p_column_id CHAR(50)
    )
BEGIN
    SELECT 
        id, 
        column_id,
        name,
        description,
        draw_order,
        UNIX_TIMESTAMP(created_at) as 'created_at', 
        UNIX_TIMESTAMP(updated_at) as 'updated_at',
        created_by,
        updated_by
    FROM Cards 
    WHERE column_id = p_column_id; 
END$$


CREATE PROCEDURE read_card_by_id(
    p_id CHAR(50)
    )
BEGIN
    SELECT 
        id, 
        column_id,
        name,
        description,
        draw_order,
        UNIX_TIMESTAMP(created_at) as 'created_at', 
        UNIX_TIMESTAMP(updated_at) as 'updated_at',
        created_by,
        updated_by
    FROM Cards 
    WHERE id = p_id; 
END$$


CREATE PROCEDURE create_card_update_record(
    p_card_id CHAR(50),
    p_added TEXT,
    p_deleted TEXT
)
BEGIN
    INSERT INTO CardUpdateRecords (
        card_id,
        added,
        deleted
    )
    VALUES (
        p_card_id,
        p_added,
        p_deleted
    );
END$$

CREATE PROCEDURE read_card_updates_by_id(p_id CHAR(50))
BEGIN
    SELECT
        card_id as 'id',
        added,
        deleted,
        UNIX_TIMESTAMP(updated_at) as 'updated_at'
    FROM CardUpdateRecords
    WHERE card_id = p_id;

END$$

DELIMITER ;