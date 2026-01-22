--
-- PostgreSQL database dump
--

-- Dumped from database version 17.0
-- Dumped by pg_dump version 17.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: decrypt_data(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.decrypt_data(encrypted_data text) RETURNS text
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN convert_from(
        decrypt(decode(encrypted_data, 'base64'),
        'ESIC_2026_FeCuOy$', 'aes'),
        'UTF8'
    );
END;
$_$;


ALTER FUNCTION public.decrypt_data(encrypted_data text) OWNER TO postgres;

--
-- Name: encrypt_data(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.encrypt_data(data text) RETURNS text
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN encode(
        encrypt(data::bytea, 'ESIC_2026_FeCuOy$', 'aes'),
        'base64'
    );
END;
$_$;


ALTER FUNCTION public.encrypt_data(data text) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.accounts (
    account_id integer NOT NULL,
    customer_id integer NOT NULL,
    account_number character varying(34) NOT NULL,
    account_type character varying(20) NOT NULL,
    balance numeric(15,2) DEFAULT 0.00,
    currency character varying(3) DEFAULT 'EUR'::character varying,
    opened_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    status character varying(20) DEFAULT 'active'::character varying,
    CONSTRAINT accounts_account_type_check CHECK (((account_type)::text = ANY ((ARRAY['checking'::character varying, 'savings'::character varying, 'business'::character varying])::text[]))),
    CONSTRAINT accounts_status_check CHECK (((status)::text = ANY ((ARRAY['active'::character varying, 'frozen'::character varying, 'closed'::character varying])::text[])))
);


ALTER TABLE public.accounts OWNER TO postgres;

--
-- Name: accounts_account_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.accounts_account_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.accounts_account_id_seq OWNER TO postgres;

--
-- Name: accounts_account_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.accounts_account_id_seq OWNED BY public.accounts.account_id;


--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audit_logs (
    log_id integer NOT NULL,
    user_id integer,
    user_role character varying(50),
    action character varying(100) NOT NULL,
    table_name character varying(50),
    record_id integer,
    ip_address character varying(45),
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.audit_logs OWNER TO postgres;

--
-- Name: audit_logs_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.audit_logs_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.audit_logs_log_id_seq OWNER TO postgres;

--
-- Name: audit_logs_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.audit_logs_log_id_seq OWNED BY public.audit_logs.log_id;


--
-- Name: cards; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cards (
    card_id integer NOT NULL,
    account_id integer NOT NULL,
    card_number text NOT NULL,
    card_type character varying(20),
    expiry_date date NOT NULL,
    cvv character varying(3) NOT NULL,
    daily_limit numeric(10,2) DEFAULT 1000.00,
    status character varying(20) DEFAULT 'active'::character varying,
    issued_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT cards_card_type_check CHECK (((card_type)::text = ANY ((ARRAY['debit'::character varying, 'credit'::character varying])::text[]))),
    CONSTRAINT cards_status_check CHECK (((status)::text = ANY ((ARRAY['active'::character varying, 'blocked'::character varying, 'expired'::character varying])::text[])))
);


ALTER TABLE public.cards OWNER TO postgres;

--
-- Name: cards_card_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cards_card_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cards_card_id_seq OWNER TO postgres;

--
-- Name: cards_card_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cards_card_id_seq OWNED BY public.cards.card_id;


--
-- Name: customers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customers (
    customer_id integer NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    first_name character varying(100) NOT NULL,
    last_name character varying(100) NOT NULL,
    date_of_birth date,
    phone character varying(20),
    address text,
    city character varying(100),
    postal_code character varying(10),
    country character varying(50) DEFAULT 'France'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    last_login timestamp without time zone,
    status character varying(20) DEFAULT 'active'::character varying,
    CONSTRAINT customers_status_check CHECK (((status)::text = ANY ((ARRAY['active'::character varying, 'suspended'::character varying, 'closed'::character varying])::text[])))
);


ALTER TABLE public.customers OWNER TO postgres;

--
-- Name: customers_customer_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.customers_customer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.customers_customer_id_seq OWNER TO postgres;

--
-- Name: customers_customer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.customers_customer_id_seq OWNED BY public.customers.customer_id;


--
-- Name: login_attempts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.login_attempts (
    attempt_id integer NOT NULL,
    email character varying(255),
    ip_address character varying(45) NOT NULL,
    user_agent text,
    success boolean NOT NULL,
    failure_reason character varying(100),
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.login_attempts OWNER TO postgres;

--
-- Name: login_attempts_attempt_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.login_attempts_attempt_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.login_attempts_attempt_id_seq OWNER TO postgres;

--
-- Name: login_attempts_attempt_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.login_attempts_attempt_id_seq OWNED BY public.login_attempts.attempt_id;


--
-- Name: transactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transactions (
    transaction_id integer NOT NULL,
    account_id integer NOT NULL,
    transaction_type character varying(20),
    amount numeric(15,2) NOT NULL,
    currency character varying(3) DEFAULT 'EUR'::character varying,
    merchant_name character varying(255),
    merchant_category character varying(50),
    location character varying(255),
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    status character varying(20) DEFAULT 'completed'::character varying,
    is_fraud boolean DEFAULT false,
    fraud_score numeric(3,2),
    CONSTRAINT transactions_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'completed'::character varying, 'failed'::character varying, 'reversed'::character varying])::text[]))),
    CONSTRAINT transactions_transaction_type_check CHECK (((transaction_type)::text = ANY ((ARRAY['deposit'::character varying, 'withdrawal'::character varying, 'transfer'::character varying, 'payment'::character varying, 'fee'::character varying])::text[])))
);


ALTER TABLE public.transactions OWNER TO postgres;

--
-- Name: transactions_transaction_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.transactions_transaction_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.transactions_transaction_id_seq OWNER TO postgres;

--
-- Name: transactions_transaction_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.transactions_transaction_id_seq OWNED BY public.transactions.transaction_id;


--
-- Name: accounts account_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts ALTER COLUMN account_id SET DEFAULT nextval('public.accounts_account_id_seq'::regclass);


--
-- Name: audit_logs log_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs ALTER COLUMN log_id SET DEFAULT nextval('public.audit_logs_log_id_seq'::regclass);


--
-- Name: cards card_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cards ALTER COLUMN card_id SET DEFAULT nextval('public.cards_card_id_seq'::regclass);


--
-- Name: customers customer_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers ALTER COLUMN customer_id SET DEFAULT nextval('public.customers_customer_id_seq'::regclass);


--
-- Name: login_attempts attempt_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.login_attempts ALTER COLUMN attempt_id SET DEFAULT nextval('public.login_attempts_attempt_id_seq'::regclass);


--
-- Name: transactions transaction_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transactions ALTER COLUMN transaction_id SET DEFAULT nextval('public.transactions_transaction_id_seq'::regclass);


--
-- Data for Name: accounts; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.accounts (account_id, customer_id, account_number, account_type, balance, currency, opened_at, status)
VALUES
  (1, 1, 'FR7612345678901234567890123', 'checking', 2500.75, 'EUR', '2026-01-18 22:59:23.831893', 'active'),
  (2, 1, 'FR7612345678901234567890124', 'savings', 15000.00, 'EUR', '2026-01-18 22:59:23.831893', 'active'),
  (3, 2, 'FR7612345678901234567890125', 'checking', 3200.50, 'EUR', '2026-01-18 22:59:23.831893', 'active'),
  (4, 3, 'FR7612345678901234567890126', 'checking', 1800.25, 'EUR', '2026-01-18 22:59:23.831893', 'active'),
  (5, 3, 'FR7612345678901234567890127', 'business', 45000.00, 'EUR', '2026-01-18 22:59:23.831893', 'active'),
  (6, 4, 'FR7612345678901234567890128', 'checking', 950.00, 'EUR', '2026-01-18 22:59:23.831893', 'active'),
  (7, 5, 'FR7612345678901234567890129', 'checking', 5500.80, 'EUR', '2026-01-18 22:59:23.831893', 'active'),
  (8, 6, 'FR7612345678901234567890130', 'checking', 2100.00, 'EUR', '2026-01-18 22:59:23.831893', 'active'),
  (9, 6, 'FR7612345678901234567890131', 'savings', 8000.00, 'EUR', '2026-01-18 22:59:23.831893', 'active'),
  (10, 7, 'FR7612345678901234567890132', 'checking', 3700.50, 'EUR', '2026-01-18 22:59:23.831893', 'active'),
  (11, 8, 'FR7612345678901234567890133', 'checking', 1200.00, 'EUR', '2026-01-18 22:59:23.831893', 'active'),
  (12, 9, 'FR7612345678901234567890134', 'checking', 4500.25, 'EUR', '2026-01-18 22:59:23.831893', 'active'),
  (13, 10, 'FR7612345678901234567890135', 'savings', 12000.00, 'EUR', '2026-01-18 22:59:23.831893', 'active');


--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--




--
-- Data for Name: cards; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.cards
  (card_id, account_id, card_number, card_type, expiry_date, cvv, daily_limit, status, issued_at)
VALUES
  (6, 7, 'nH3EtUu29GUflbSehmZgfUIcWNCmSsXzwgzDXeWu9iM=', 'debit', '2028-01-31', '890', 1000.00, 'active', '2026-01-18 22:59:23.834502'),
  (7, 9, 'z6gxqVF9iUTflSnO9kyVOuLvLDGJaTruy7PtwMSCeBY=', 'debit', '2027-08-31', '345', 1200.00, 'active', '2026-01-18 22:59:23.834502'),
  (8, 10, 'R7nwtEVlN5Q8YCq8gaLGMC5kU7B4woJeU+NRQ7nMS7I=', 'credit', '2028-05-31', '678', 2500.00, 'active', '2026-01-18 22:59:23.834502'),
  (9, 12, 'cQ2kk2eOrprompYn87VSAQ58Vc5gzlqbKBqGf+doTbQ=', 'debit', '2027-10-31', '901', 800.00, 'active', '2026-01-18 22:59:23.834502'),
  (10, 13, 'wLbr4D9AqdYOszvTGm27FBbAaTBB/16zGVVsVlvz0OI=', 'debit', '2028-02-28', '012', 1500.00, 'active', '2026-01-18 22:59:23.834502'),
  (1, 1, '3TPu4IsaR/EZ47DhxqrE7pDeZGWEfY/3mdG1eZgZoS38Vu6n9olzM+MfhdFH8hc5', 'debit', '2027-12-31', '123', 1000.00, 'active', '2026-01-18 22:59:23.834502'),
  (2, 2, '9jwThdXagwFZETTPuLDvv1uGL4ZSi7tLQLXzBSMnrfk4GhIgOU4Un3QrqPPUU3bg', 'debit', '2028-06-30', '456', 500.00, 'active', '2026-01-18 22:59:23.834502'),
  (3, 3, 'oK6xyggPXx7tF0z8L7rzKfntnT3pQ6IObzRGKBQ+yQ7LD/ty7xO2Ztg1C6ozUp4N', 'debit', '2027-09-30', '789', 1500.00, 'active', '2026-01-18 22:59:23.834502'),
  (4, 4, 'VTzeu/l8zFjHPO9MlMgbIbkydnaVyQy9LlY4P2pezXnw5C/pvjBUbpAO+GNwttLo', 'credit', '2028-03-31', '234', 3000.00, 'active', '2026-01-18 22:59:23.834502'),
  (5, 5, 'J7Ezb0dkBFwxVMlclh7eE+JSQc4SCjGGcM7erhZm3XMXBXLOWx30m9HkZExvzMV+', 'debit', '2027-11-30', '567', 2000.00, 'active', '2026-01-18 22:59:23.834502');


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.customers
  (customer_id, email, password_hash, first_name, last_name, date_of_birth, phone, address, city, postal_code, country, created_at, last_login, status)
VALUES
  (1, 'jean.dupont@email.fr', '$2b$12$abcdefghijklmnopqrstuvwxyz12345', 'Jean', 'Dupont', '1985-03-15', '0601020304', '12 Rue de la Paix', 'Paris', '75001', 'France', '2026-01-18 22:59:23.828436', NULL, 'active'),
  (2, 'marie.martin@email.fr', '$2b$12$bcdefghijklmnopqrstuvwxyz123456', 'Marie', 'Martin', '1990-07-22', '0612345678', '45 Avenue des Champs', 'Lyon', '69001', 'France', '2026-01-18 22:59:23.828436', NULL, 'active'),
  (3, 'pierre.bernard@email.fr', '$2b$12$cdefghijklmnopqrstuvwxyz1234567', 'Pierre', 'Bernard', '1982-11-08', '0623456789', '8 Boulevard Victor Hugo', 'Marseille', '13001', 'France', '2026-01-18 22:59:23.828436', NULL, 'active'),
  (4, 'sophie.petit@email.fr', '$2b$12$defghijklmnopqrstuvwxyz12345678', 'Sophie', 'Petit', '1995-02-14', '0634567890', '3 Rue Gambetta', 'Toulouse', '31000', 'France', '2026-01-18 22:59:23.828436', NULL, 'active'),
  (5, 'luc.durand@email.fr', '$2b$12$efghijklmnopqrstuvwxyz123456789', 'Luc', 'Durand', '1988-09-30', '0645678901', '15 All├â┬®e des Platanes', 'Nice', '06000', 'France', '2026-01-18 22:59:23.828436', NULL, 'active'),
  (6, 'claire.moreau@email.fr', '$2b$12$fghijklmnopqrstuvwxyz1234567890', 'Claire', 'Moreau', '1992-05-18', '0656789012', '22 Rue de la R├â┬®publique', 'Nantes', '44000', 'France', '2026-01-18 22:59:23.828436', NULL, 'active'),
  (7, 'thomas.simon@email.fr', '$2b$12$ghijklmnopqrstuvwxyz12345678901', 'Thomas', 'Simon', '1980-12-25', '0667890123', '9 Place du March├â┬®', 'Strasbourg', '67000', 'France', '2026-01-18 22:59:23.828436', NULL, 'active'),
  (8, 'emma.laurent@email.fr', '$2b$12$hijklmnopqrstuvwxyz123456789012', 'Emma', 'Laurent', '1997-08-03', '0678901234', '31 Avenue de la Libert├â┬®', 'Bordeaux', '33000', 'France', '2026-01-18 22:59:23.828436', NULL, 'active'),
  (9, 'nicolas.lefebvre@email.fr', '$2b$12$ijklmnopqrstuvwxyz1234567890123', 'Nicolas', 'Lefebvre', '1986-04-12', '0689012345', '7 Rue Saint-Michel', 'Lille', '59000', 'France', '2026-01-18 22:59:23.828436', NULL, 'active'),
  (10, 'amelie.roux@email.fr', '$2b$12$jklmnopqrstuvwxyz12345678901234', 'Am├â┬®lie', 'Roux', '1993-10-27', '0690123456', '18 Cours Lafayette', 'Rennes', '35000', 'France', '2026-01-18 22:59:23.828436', NULL, 'active');


--
-- Data for Name: login_attempts; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.login_attempts
  (attempt_id, email, ip_address, user_agent, success, failure_reason, "timestamp")
VALUES
  (1, 'jean.dupont@email.fr', '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0)', true, NULL, '2026-01-18 22:59:23.840835'),
  (2, 'marie.martin@email.fr', '192.168.1.101', 'Mozilla/5.0 (Macintosh)', true, NULL, '2026-01-18 22:59:23.840835'),
  (3, 'invalid@email.fr', '45.123.45.67', 'curl/7.68.0', false, 'invalid_email', '2026-01-18 22:59:23.840835'),
  (4, 'jean.dupont@email.fr', '45.123.45.67', 'Python-requests', false, 'invalid_password', '2026-01-18 22:59:23.840835'),
  (5, 'jean.dupont@email.fr', '45.123.45.67', 'Python-requests', false, 'invalid_password', '2026-01-18 22:59:23.840835'),
  (6, 'jean.dupont@email.fr', '45.123.45.67', 'Python-requests', false, 'invalid_password', '2026-01-18 22:59:23.840835'),
  (7, 'pierre.bernard@email.fr', '192.168.1.102', 'Mozilla/5.0 (iPhone)', true, NULL, '2026-01-18 22:59:23.840835'),
  (8, 'admin@digitalbank.fr', '89.234.56.78', 'curl/7.68.0', false, 'invalid_email', '2026-01-18 22:59:23.840835'),
  (9, 'admin@digitalbank.fr', '89.234.56.78', 'curl/7.68.0', false, 'invalid_email', '2026-01-18 22:59:23.840835'),
  (10, 'sophie.petit@email.fr', '192.168.1.103', 'Mozilla/5.0 (Android)', true, NULL, '2026-01-18 22:59:23.840835');


--
-- Data for Name: transactions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.transactions
  (transaction_id, account_id, transaction_type, amount, currency, merchant_name, merchant_category, location, "timestamp", status, is_fraud, fraud_score)
VALUES
  (1, 1, 'payment', -45.50, 'EUR', 'Carrefour Market', 'Groceries', 'Paris, France', '2026-01-18 22:59:23.836707', 'completed', false, NULL),
  (2, 1, 'payment', -120.00, 'EUR', 'SNCF', 'Travel', 'Lyon, France', '2026-01-18 22:59:23.836707', 'completed', false, NULL),
  (3, 1, 'deposit', 1500.00, 'EUR', 'Salary', 'Income', 'Paris, France', '2026-01-18 22:59:23.836707', 'completed', false, NULL),
  (4, 3, 'payment', -89.99, 'EUR', 'Amazon.fr', 'Electronics', 'Online', '2026-01-18 22:59:23.836707', 'completed', false, NULL),
  (5, 3, 'payment', -25.30, 'EUR', 'Starbucks', 'Food & Beverage', 'Paris, France', '2026-01-18 22:59:23.836707', 'completed', false, NULL),
  (6, 5, 'transfer', -500.00, 'EUR', 'Transfer to savings', 'Transfer', 'Online', '2026-01-18 22:59:23.836707', 'completed', false, NULL),
  (7, 5, 'payment', -150.00, 'EUR', 'EDF', 'Utilities', 'Online', '2026-01-18 22:59:23.836707', 'completed', false, NULL),
  (8, 7, 'payment', -200.00, 'EUR', 'Nike Store', 'Clothing', 'Lyon, France', '2026-01-18 22:59:23.836707', 'completed', false, NULL),
  (9, 9, 'payment', -75.50, 'EUR', 'Auchan', 'Groceries', 'Lille, France', '2026-01-18 22:59:23.836707', 'completed', false, NULL),
  (10, 10, 'deposit', 2000.00, 'EUR', 'Salary', 'Income', 'Rennes, France', '2026-01-18 22:59:23.836707', 'completed', false, NULL),
  (11, 1, 'payment', -12.50, 'EUR', 'Boulangerie Paul', 'Food & Beverage', 'Paris, France', '2026-01-18 22:59:23.836707', 'completed', false, NULL),
  (12, 3, 'payment', -350.00, 'EUR', 'FNAC', 'Electronics', 'Paris, France', '2026-01-18 22:59:23.836707', 'completed', false, NULL),
  (13, 4, 'payment', -80.00, 'EUR', 'Shell Station', 'Fuel', 'Marseille, France', '2026-01-18 22:59:23.836707', 'completed', false, NULL),
  (14, 7, 'payment', -450.00, 'EUR', 'Air France', 'Travel', 'Online', '2026-01-18 22:59:23.836707', 'completed', false, NULL),
  (15, 9, 'withdrawal', -100.00, 'EUR', 'ATM Withdrawal', 'Cash', 'Lille, France', '2026-01-18 22:59:23.836707', 'completed', false, NULL),
  (16, 1, 'payment', -2500.00, 'EUR', 'Unknown Merchant', 'Electronics', 'Dubai, UAE', '2026-01-18 22:59:23.836707', 'completed', true, NULL),
  (17, 3, 'payment', -3500.00, 'EUR', 'Luxury Goods Store', 'Jewelry', 'Hong Kong', '2026-01-18 22:59:23.836707', 'completed', true, NULL),
  (18, 5, 'payment', -1800.00, 'EUR', 'Casino Royal', 'Gambling', 'Las Vegas, USA', '2026-01-18 22:59:23.836707', 'completed', true, NULL),
  (19, 7, 'payment', -4000.00, 'EUR', 'Cryptocurrency Exchange', 'Finance', 'Online', '2026-01-18 22:59:23.836707', 'completed', true, NULL),
  (20, 1, 'payment', -150.00, 'EUR', 'Unknown Website', 'Online Shopping', 'Unknown', '2026-01-18 22:59:23.836707', 'completed', true, NULL),
  (21, 3, 'payment', -2200.00, 'EUR', 'Gift Cards Store', 'Retail', 'Online', '2026-01-18 22:59:23.836707', 'completed', true, NULL),
  (22, 5, 'payment', -1500.00, 'EUR', 'International Wire', 'Transfer', 'Nigeria', '2026-01-18 22:59:23.836707', 'completed', true, NULL),
  (23, 9, 'payment', -800.00, 'EUR', 'Bitcoin ATM', 'Cryptocurrency', 'Paris, France', '2026-01-18 22:59:23.836707', 'completed', true, NULL),
  (24, 10, 'payment', -5000.00, 'EUR', 'Wire Transfer', 'Transfer', 'Russia', '2026-01-18 22:59:23.836707', 'completed', true, NULL),
  (25, 1, 'payment', -200.00, 'EUR', 'Suspicious Merchant ABC', 'Unknown', 'Online', '2026-01-18 22:59:23.836707', 'completed', true, NULL),
  (26, 4, 'payment', -35.00, 'EUR', 'McDonald''s', 'Food & Beverage', 'Marseille, France', '2026-01-18 22:59:23.836707', 'completed', false, NULL),
  (27, 7, 'payment', -60.00, 'EUR', 'Pharmacie', 'Health', 'Strasbourg, France', '2026-01-18 22:59:23.836707', 'completed', false, NULL),
  (28, 10, 'payment', -180.00, 'EUR', 'H&M', 'Clothing', 'Rennes, France', '2026-01-18 22:59:23.836707', 'completed', false, NULL),
  (29, 12, 'payment', -95.00, 'EUR', 'Cinema Gaumont', 'Entertainment', 'Bordeaux, France', '2026-01-18 22:59:23.836707', 'completed', false, NULL),
  (30, 13, 'payment', -250.00, 'EUR', 'Hotel Ibis', 'Travel', 'Nice, France', '2026-01-18 22:59:23.836707', 'completed', false, NULL);


--
-- Name: accounts_account_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.accounts_account_id_seq', 13, true);


--
-- Name: audit_logs_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.audit_logs_log_id_seq', 1, false);


--
-- Name: cards_card_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cards_card_id_seq', 10, true);


--
-- Name: customers_customer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.customers_customer_id_seq', 10, true);


--
-- Name: login_attempts_attempt_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.login_attempts_attempt_id_seq', 10, true);


--
-- Name: transactions_transaction_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.transactions_transaction_id_seq', 30, true);


--
-- Name: accounts accounts_account_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_account_number_key UNIQUE (account_number);


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (account_id);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (log_id);


--
-- Name: cards cards_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT cards_pkey PRIMARY KEY (card_id);


--
-- Name: customers customers_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_email_key UNIQUE (email);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (customer_id);


--
-- Name: login_attempts login_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.login_attempts
    ADD CONSTRAINT login_attempts_pkey PRIMARY KEY (attempt_id);


--
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (transaction_id);


--
-- Name: idx_login_attempts_ip; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_login_attempts_ip ON public.login_attempts USING btree (ip_address);


--
-- Name: idx_login_attempts_timestamp; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_login_attempts_timestamp ON public.login_attempts USING btree ("timestamp");


--
-- Name: idx_transactions_account_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transactions_account_id ON public.transactions USING btree (account_id);


--
-- Name: idx_transactions_is_fraud; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transactions_is_fraud ON public.transactions USING btree (is_fraud);


--
-- Name: idx_transactions_timestamp; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transactions_timestamp ON public.transactions USING btree ("timestamp");


--
-- Name: accounts accounts_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id) ON DELETE CASCADE;


--
-- Name: cards cards_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT cards_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(account_id) ON DELETE CASCADE;


--
-- Name: transactions transactions_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(account_id) ON DELETE CASCADE;


--
-- Name: TABLE accounts; Type: ACL; Schema: public; Owner: postgres
--

--GRANT ALL ON TABLE public.accounts TO admin_role;
--GRANT SELECT ON TABLE public.accounts TO analyst_role;
--GRANT SELECT,INSERT,UPDATE ON TABLE public.accounts TO app_role;


--
-- Name: SEQUENCE accounts_account_id_seq; Type: ACL; Schema: public; Owner: postgres
--

--GRANT ALL ON SEQUENCE public.accounts_account_id_seq TO admin_role;


--
-- Name: TABLE audit_logs; Type: ACL; Schema: public; Owner: postgres
--

--GRANT ALL ON TABLE public.audit_logs TO admin_role;
--GRANT SELECT ON TABLE public.audit_logs TO analyst_role;


--
-- Name: SEQUENCE audit_logs_log_id_seq; Type: ACL; Schema: public; Owner: postgres
--

--GRANT ALL ON SEQUENCE public.audit_logs_log_id_seq TO admin_role;


--
-- Name: TABLE cards; Type: ACL; Schema: public; Owner: postgres
--

--GRANT ALL ON TABLE public.cards TO admin_role;
--GRANT SELECT ON TABLE public.cards TO analyst_role;
--GRANT SELECT,INSERT,UPDATE ON TABLE public.cards TO app_role;


--
-- Name: SEQUENCE cards_card_id_seq; Type: ACL; Schema: public; Owner: postgres
--

--GRANT ALL ON SEQUENCE public.cards_card_id_seq TO admin_role;


--
-- Name: TABLE customers; Type: ACL; Schema: public; Owner: postgres
--

--GRANT ALL ON TABLE public.customers TO admin_role;
--GRANT SELECT ON TABLE public.customers TO analyst_role;
--GRANT SELECT,INSERT,UPDATE ON TABLE public.customers TO app_role;


--
-- Name: SEQUENCE customers_customer_id_seq; Type: ACL; Schema: public; Owner: postgres
--

--GRANT ALL ON SEQUENCE public.customers_customer_id_seq TO admin_role;


--
-- Name: TABLE login_attempts; Type: ACL; Schema: public; Owner: postgres
--

--GRANT ALL ON TABLE public.login_attempts TO admin_role;
--GRANT SELECT ON TABLE public.login_attempts TO analyst_role;


--
-- Name: SEQUENCE login_attempts_attempt_id_seq; Type: ACL; Schema: public; Owner: postgres
--

--GRANT ALL ON SEQUENCE public.login_attempts_attempt_id_seq TO admin_role;


--
-- Name: TABLE transactions; Type: ACL; Schema: public; Owner: postgres
--

--GRANT ALL ON TABLE public.transactions TO admin_role;
--GRANT SELECT ON TABLE public.transactions TO analyst_role;
--GRANT SELECT,INSERT,UPDATE ON TABLE public.transactions TO app_role;


--
-- Name: SEQUENCE transactions_transaction_id_seq; Type: ACL; Schema: public; Owner: postgres
--

--GRANT ALL ON SEQUENCE public.transactions_transaction_id_seq TO --admin_role;


--
-- PostgreSQL database dump complete
--

