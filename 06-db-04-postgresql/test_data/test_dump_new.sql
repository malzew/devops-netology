--
-- PostgreSQL database dump
--

-- Dumped from database version 13.7 (Debian 13.7-1.pgdg110+1)
-- Dumped by pg_dump version 13.7 (Debian 13.7-1.pgdg110+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    id integer NOT NULL,
    title character varying(80) NOT NULL,
    price integer
)
PARTITION BY RANGE (price);


ALTER TABLE public.orders OWNER TO postgres;

--
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.orders_id_seq OWNER TO postgres;

--
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;


SET default_table_access_method = heap;

--
-- Name: orders_1; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders_1 (
    id integer DEFAULT nextval('public.orders_id_seq'::regclass) NOT NULL,
    title character varying(80) NOT NULL,
    price integer
);
ALTER TABLE ONLY public.orders ATTACH PARTITION public.orders_1 FOR VALUES FROM (500) TO (MAXVALUE);


ALTER TABLE public.orders_1 OWNER TO postgres;

--
-- Name: orders_2; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders_2 (
    id integer DEFAULT nextval('public.orders_id_seq'::regclass) NOT NULL,
    title character varying(80) NOT NULL,
    price integer
);
ALTER TABLE ONLY public.orders ATTACH PARTITION public.orders_2 FOR VALUES FROM (MINVALUE) TO (500);


ALTER TABLE public.orders_2 OWNER TO postgres;

--
-- Name: orders id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);


--
-- Data for Name: orders_1; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders_1 (id, title, price) FROM stdin;
2	My little database	500
6	WAL never lies	900
8	Dbiezdmin	501
11	Privet 3	500
12	Privet 4	500
13	Privet 5	520
14	Privet 6	600
16	Privet 8	700
\.


--
-- Data for Name: orders_2; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders_2 (id, title, price) FROM stdin;
1	War and peace	100
3	Adventure psql time	300
4	Server gravity falls	300
5	Log gossips	123
7	Me and my bash-pet	499
9	Privet 1	499
10	Privet 2	499
15	Privet 7	400
\.


--
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.orders_id_seq', 16, true);


--
-- Name: orders_1 orders_1_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders_1
    ADD CONSTRAINT orders_1_pkey PRIMARY KEY (id);


--
-- Name: orders_2 orders_2_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders_2
    ADD CONSTRAINT orders_2_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

ALTER TABLE public.orders_1 ADD UNIQUE(title);
ALTER TABLE public.orders_2 ADD UNIQUE(title);

