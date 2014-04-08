--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: groupings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE groupings (
    id integer NOT NULL,
    key_line character varying(255),
    error_class character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    state character varying(255) DEFAULT 'active'::character varying NOT NULL,
    last_emailed_at timestamp without time zone,
    message text,
    popularity numeric(1000,1),
    latest_wat_at timestamp without time zone
);


--
-- Name: groupings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE groupings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: groupings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE groupings_id_seq OWNED BY groupings.id;


--
-- Name: notes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE notes (
    id integer NOT NULL,
    watcher_id integer,
    grouping_id integer,
    message text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: notes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE notes_id_seq OWNED BY notes.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: watchers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE watchers (
    id integer NOT NULL,
    first_name character varying(255),
    name character varying(255),
    email character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: watchers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE watchers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: watchers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE watchers_id_seq OWNED BY watchers.id;


--
-- Name: wats; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE wats (
    id integer NOT NULL,
    message text,
    error_class text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    session hstore,
    request_headers hstore,
    request_params hstore,
    page_url text,
    app_env text DEFAULT 'unknown'::character varying NOT NULL,
    sidekiq_msg hstore,
    app_name text DEFAULT 'unknown'::character varying NOT NULL,
    backtrace text[],
    language character varying(255),
    app_user hstore DEFAULT '"id"=>NULL'::hstore
);


--
-- Name: wats_groupings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE wats_groupings (
    id integer NOT NULL,
    wat_id integer NOT NULL,
    grouping_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    state character varying(255) NOT NULL
);


--
-- Name: wats_groupings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE wats_groupings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wats_groupings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE wats_groupings_id_seq OWNED BY wats_groupings.id;


--
-- Name: wats_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE wats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE wats_id_seq OWNED BY wats.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY groupings ALTER COLUMN id SET DEFAULT nextval('groupings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY notes ALTER COLUMN id SET DEFAULT nextval('notes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY watchers ALTER COLUMN id SET DEFAULT nextval('watchers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY wats ALTER COLUMN id SET DEFAULT nextval('wats_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY wats_groupings ALTER COLUMN id SET DEFAULT nextval('wats_groupings_id_seq'::regclass);


--
-- Name: groupings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY groupings
    ADD CONSTRAINT groupings_pkey PRIMARY KEY (id);


--
-- Name: notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY notes
    ADD CONSTRAINT notes_pkey PRIMARY KEY (id);


--
-- Name: watchers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY watchers
    ADD CONSTRAINT watchers_pkey PRIMARY KEY (id);


--
-- Name: wats_groupings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY wats_groupings
    ADD CONSTRAINT wats_groupings_pkey PRIMARY KEY (id);


--
-- Name: wats_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY wats
    ADD CONSTRAINT wats_pkey PRIMARY KEY (id);


--
-- Name: index_groupings_on_key_line_and_error_class; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_groupings_on_key_line_and_error_class ON groupings USING btree (key_line, error_class);


--
-- Name: index_groupings_on_latest_wat_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_groupings_on_latest_wat_at ON groupings USING btree (latest_wat_at);


--
-- Name: index_groupings_on_message; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_groupings_on_message ON groupings USING btree (message);


--
-- Name: index_groupings_on_popularity; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_groupings_on_popularity ON groupings USING btree (popularity);


--
-- Name: index_groupings_on_state; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_groupings_on_state ON groupings USING btree (state);


--
-- Name: index_notes_on_grouping_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_notes_on_grouping_id ON notes USING btree (grouping_id);


--
-- Name: index_notes_on_watcher_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_notes_on_watcher_id ON notes USING btree (watcher_id);


--
-- Name: index_wats_groupings_on_grouping_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_wats_groupings_on_grouping_id ON wats_groupings USING btree (grouping_id);


--
-- Name: index_wats_groupings_on_grouping_id_and_wat_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_wats_groupings_on_grouping_id_and_wat_id ON wats_groupings USING btree (grouping_id, wat_id);


--
-- Name: index_wats_groupings_on_state_and_grouping_id_and_wat_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_wats_groupings_on_state_and_grouping_id_and_wat_id ON wats_groupings USING btree (state, grouping_id, wat_id);


--
-- Name: index_wats_groupings_on_wat_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_wats_groupings_on_wat_id ON wats_groupings USING btree (wat_id);


--
-- Name: index_wats_on_app_env; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_wats_on_app_env ON wats USING btree (app_env);


--
-- Name: index_wats_on_app_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_wats_on_app_name ON wats USING btree (app_name);


--
-- Name: index_wats_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_wats_on_created_at ON wats USING btree (created_at);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: wats_user_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX wats_user_index ON wats USING gin (app_user);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20130330230521');

INSERT INTO schema_migrations (version) VALUES ('20130330231716');

INSERT INTO schema_migrations (version) VALUES ('20130331063841');

INSERT INTO schema_migrations (version) VALUES ('20130331063932');

INSERT INTO schema_migrations (version) VALUES ('20130405042638');

INSERT INTO schema_migrations (version) VALUES ('20130418161032');

INSERT INTO schema_migrations (version) VALUES ('20130418161235');

INSERT INTO schema_migrations (version) VALUES ('20130418161513');

INSERT INTO schema_migrations (version) VALUES ('20130422042733');

INSERT INTO schema_migrations (version) VALUES ('20130427192026');

INSERT INTO schema_migrations (version) VALUES ('20130427222513');

INSERT INTO schema_migrations (version) VALUES ('20130527210405');

INSERT INTO schema_migrations (version) VALUES ('20130619184758');

INSERT INTO schema_migrations (version) VALUES ('20130709004705');

INSERT INTO schema_migrations (version) VALUES ('20130710213002');

INSERT INTO schema_migrations (version) VALUES ('20130723165724');

INSERT INTO schema_migrations (version) VALUES ('20130725184605');

INSERT INTO schema_migrations (version) VALUES ('20130731211525');

INSERT INTO schema_migrations (version) VALUES ('20130806175504');

INSERT INTO schema_migrations (version) VALUES ('20130808214058');

INSERT INTO schema_migrations (version) VALUES ('20130808222224');

INSERT INTO schema_migrations (version) VALUES ('20131122175708');

INSERT INTO schema_migrations (version) VALUES ('20131126191956');

INSERT INTO schema_migrations (version) VALUES ('20131210221143');

INSERT INTO schema_migrations (version) VALUES ('20140117210801');

INSERT INTO schema_migrations (version) VALUES ('20140121232448');

INSERT INTO schema_migrations (version) VALUES ('20140211190623');

INSERT INTO schema_migrations (version) VALUES ('20140408181823');
