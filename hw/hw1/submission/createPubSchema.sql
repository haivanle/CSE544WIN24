-- CREATEDB dblp
-- PSQL dblp
-- DROPDB dblp

DROP TABLE IF EXISTS AUTHOR CASCADE;
DROP TABLE IF EXISTS PUBLICATION CASCADE;
DROP TABLE IF EXISTS AUTHORED CASCADE;
DROP TABLE IF EXISTS ARTICLE CASCADE;
DROP TABLE IF EXISTS BOOK CASCADE;
DROP TABLE IF EXISTS INCOLLECTION CASCADE;
DROP TABLE IF EXISTS INPROCEEDINGS CASCADE;

CREATE TABLE AUTHOR (
    ID INT NOT NULL UNIQUE PRIMARY KEY,
    NAME           TEXT NOT NULL,
    HOMEPAGE       TEXT
);

CREATE TABLE PUBLICATION (
    PUBID   INT NOT NULL PRIMARY KEY,
    PUBKEY              TEXT NOT NULL,
    TITLE               TEXT,
    YEAR                TEXT
);

CREATE TABLE AUTHORED (
    ID      INT NOT NULL REFERENCES AUTHOR(ID),
    PUBID   INT NOT NULL REFERENCES PUBLICATION(PUBID),
    PRIMARY KEY (ID, PUBID)
);

CREATE TABLE ARTICLE (
    PUBID   INT NOT NULL REFERENCES PUBLICATION(PUBID),
    PRIMARY KEY (PUBID),
    JOURNAL TEXT,
    MONTH   TEXT,
    VOLUME  TEXT,
    NUMBER  TEXT
);

CREATE TABLE BOOK (
    PUBID INT NOT NULL REFERENCES PUBLICATION(PUBID),
    PRIMARY KEY (PUBID),
    PUBLISHER TEXT,
    ISBN      TEXT
);

CREATE TABLE INCOLLECTION (
    PUBID INT NOT NULL REFERENCES PUBLICATION(PUBID),
    PRIMARY KEY (PUBID),
    BOOKTITLE TEXT,
    PUBLISHER TEXT,
    ISBN      TEXT
);

CREATE TABLE INPROCEEDINGS (
    PUBID INT NOT NULL REFERENCES PUBLICATION(PUBID),
    PRIMARY KEY (PUBID),
    BOOKTITLE TEXT,
    EDITOR    TEXT
)
