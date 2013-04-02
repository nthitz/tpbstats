--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.8
-- Dumped by pg_dump version 9.1.8
-- Started on 2013-04-01 23:43:57 PDT

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 167 (class 3079 OID 11680)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 1928 (class 0 OID 0)
-- Dependencies: 167
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 165 (class 1259 OID 228782)
-- Dependencies: 5
-- Name: torrent_category; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE torrent_category (
    category_id integer NOT NULL,
    name text
);


ALTER TABLE public.torrent_category OWNER TO postgres;

--
-- TOC entry 164 (class 1259 OID 228780)
-- Dependencies: 165 5
-- Name: category_category_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE category_category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.category_category_id_seq OWNER TO postgres;

--
-- TOC entry 1929 (class 0 OID 0)
-- Dependencies: 164
-- Name: category_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE category_category_id_seq OWNED BY torrent_category.category_id;


--
-- TOC entry 162 (class 1259 OID 24965)
-- Dependencies: 5
-- Name: comment; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE comment (
    tpb_id integer,
    posted timestamp without time zone,
    msg text,
    comment_id integer NOT NULL
);


ALTER TABLE public.comment OWNER TO postgres;

--
-- TOC entry 163 (class 1259 OID 33573)
-- Dependencies: 162 5
-- Name: comment_comment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE comment_comment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.comment_comment_id_seq OWNER TO postgres;

--
-- TOC entry 1930 (class 0 OID 0)
-- Dependencies: 163
-- Name: comment_comment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE comment_comment_id_seq OWNED BY comment.comment_id;


--
-- TOC entry 161 (class 1259 OID 24945)
-- Dependencies: 5
-- Name: torrent; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE torrent (
    tpb_id integer NOT NULL,
    title text,
    magnet text,
    size bigint,
    seeders integer,
    leechers integer,
    uploaded timestamp without time zone,
    nfo text,
    upvotes integer,
    downvotes integer,
    comment_count integer
);


ALTER TABLE public.torrent OWNER TO postgres;

--
-- TOC entry 166 (class 1259 OID 228803)
-- Dependencies: 1908 5
-- Name: torrent_additional; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE torrent_additional (
    tpb_id integer NOT NULL,
    "user" text,
    tags text,
    pic text,
    category_id integer DEFAULT (-1)
);


ALTER TABLE public.torrent_additional OWNER TO postgres;

--
-- TOC entry 1906 (class 2604 OID 33575)
-- Dependencies: 163 162
-- Name: comment_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY comment ALTER COLUMN comment_id SET DEFAULT nextval('comment_comment_id_seq'::regclass);


--
-- TOC entry 1907 (class 2604 OID 228785)
-- Dependencies: 165 164 165
-- Name: category_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY torrent_category ALTER COLUMN category_id SET DEFAULT nextval('category_category_id_seq'::regclass);


--
-- TOC entry 1916 (class 2606 OID 228790)
-- Dependencies: 165 165 1922
-- Name: category_id; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY torrent_category
    ADD CONSTRAINT category_id PRIMARY KEY (category_id);


--
-- TOC entry 1913 (class 2606 OID 33583)
-- Dependencies: 162 162 1922
-- Name: comment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY comment
    ADD CONSTRAINT comment_pkey PRIMARY KEY (comment_id);


--
-- TOC entry 1918 (class 2606 OID 228810)
-- Dependencies: 166 166 1922
-- Name: primary; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY torrent_additional
    ADD CONSTRAINT "primary" PRIMARY KEY (tpb_id);


--
-- TOC entry 1911 (class 2606 OID 33585)
-- Dependencies: 161 161 1922
-- Name: tpb_id; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY torrent
    ADD CONSTRAINT tpb_id PRIMARY KEY (tpb_id);


--
-- TOC entry 1914 (class 1259 OID 227898)
-- Dependencies: 162 1922
-- Name: comment_tpb_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX comment_tpb_id_idx ON comment USING btree (tpb_id);


--
-- TOC entry 1909 (class 1259 OID 228760)
-- Dependencies: 161 1922
-- Name: title; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX title ON torrent USING btree (title);


--
-- TOC entry 1920 (class 2606 OID 228842)
-- Dependencies: 165 166 1915 1922
-- Name: category_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY torrent_additional
    ADD CONSTRAINT category_id FOREIGN KEY (category_id) REFERENCES torrent_category(category_id);


--
-- TOC entry 1919 (class 2606 OID 228837)
-- Dependencies: 1910 161 166 1922
-- Name: tpb_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY torrent_additional
    ADD CONSTRAINT tpb_id_foreign FOREIGN KEY (tpb_id) REFERENCES torrent(tpb_id);


--
-- TOC entry 1927 (class 0 OID 0)
-- Dependencies: 5
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2013-04-01 23:43:58 PDT

--
-- PostgreSQL database dump complete
--

