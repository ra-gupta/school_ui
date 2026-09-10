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
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: academic_years; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.academic_years (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    name character varying NOT NULL,
    starts_on date NOT NULL,
    ends_on date NOT NULL,
    current boolean DEFAULT false NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: academic_years_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.academic_years_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: academic_years_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.academic_years_id_seq OWNED BY public.academic_years.id;


--
-- Name: admission_enquiries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admission_enquiries (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    grade_id bigint,
    assigned_to_id bigint,
    student_name character varying NOT NULL,
    guardian_name character varying,
    phone character varying,
    email character varying,
    source character varying,
    status character varying DEFAULT 'new'::character varying NOT NULL,
    enquired_on date NOT NULL,
    follow_up_on date,
    notes text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: admission_enquiries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admission_enquiries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admission_enquiries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admission_enquiries_id_seq OWNED BY public.admission_enquiries.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: assets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assets (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    assigned_to_id bigint,
    name character varying NOT NULL,
    code character varying,
    category character varying,
    purchased_on date,
    cost numeric(12,2),
    location character varying,
    condition character varying DEFAULT 'good'::character varying NOT NULL,
    status character varying DEFAULT 'in_use'::character varying NOT NULL,
    warranty_expires_on date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: assets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.assets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.assets_id_seq OWNED BY public.assets.id;


--
-- Name: attendances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attendances (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    academic_year_id bigint,
    attendable_type character varying NOT NULL,
    attendable_id bigint NOT NULL,
    section_id bigint,
    marked_by_id bigint,
    on_date date NOT NULL,
    status character varying DEFAULT 'present'::character varying NOT NULL,
    source character varying DEFAULT 'manual'::character varying NOT NULL,
    check_in time without time zone,
    check_out time without time zone,
    remarks character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: attendances_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.attendances_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attendances_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.attendances_id_seq OWNED BY public.attendances.id;


--
-- Name: biometric_devices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.biometric_devices (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    serial_number character varying NOT NULL,
    name character varying,
    ip_address character varying,
    location character varying,
    last_seen_at timestamp(6) without time zone,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: biometric_devices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.biometric_devices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: biometric_devices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.biometric_devices_id_seq OWNED BY public.biometric_devices.id;


--
-- Name: biometric_punches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.biometric_punches (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    biometric_device_id bigint,
    biometric_id character varying NOT NULL,
    punched_at timestamp(6) without time zone NOT NULL,
    punch_state integer,
    verify_mode integer,
    processed boolean DEFAULT false NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: biometric_punches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.biometric_punches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: biometric_punches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.biometric_punches_id_seq OWNED BY public.biometric_punches.id;


--
-- Name: book_issues; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.book_issues (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    book_id bigint NOT NULL,
    student_id bigint,
    staff_id bigint,
    issued_on date NOT NULL,
    due_on date NOT NULL,
    returned_on date,
    fine numeric(8,2) DEFAULT 0.0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: book_issues_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.book_issues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: book_issues_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.book_issues_id_seq OWNED BY public.book_issues.id;


--
-- Name: books; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.books (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    title character varying NOT NULL,
    author character varying,
    isbn character varying,
    publisher character varying,
    category character varying,
    rack character varying,
    copies integer DEFAULT 1 NOT NULL,
    available integer DEFAULT 1 NOT NULL,
    price numeric(10,2),
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: books_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.books_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: books_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.books_id_seq OWNED BY public.books.id;


--
-- Name: cameras; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cameras (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    name character varying NOT NULL,
    location character varying,
    stream_url character varying,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: cameras_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cameras_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cameras_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cameras_id_seq OWNED BY public.cameras.id;


--
-- Name: campus_workers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.campus_workers (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    name character varying NOT NULL,
    role character varying,
    phone character varying,
    shift character varying,
    daily_wage numeric(10,2),
    joined_on date,
    status character varying DEFAULT 'active'::character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: campus_workers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.campus_workers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: campus_workers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.campus_workers_id_seq OWNED BY public.campus_workers.id;


--
-- Name: certificate_templates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.certificate_templates (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    name character varying NOT NULL,
    kind character varying DEFAULT 'bonafide'::character varying NOT NULL,
    body text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: certificate_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.certificate_templates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: certificate_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.certificate_templates_id_seq OWNED BY public.certificate_templates.id;


--
-- Name: chat_messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.chat_messages (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    conversation_id bigint NOT NULL,
    sender_id bigint NOT NULL,
    body text NOT NULL,
    read_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: chat_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.chat_messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: chat_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.chat_messages_id_seq OWNED BY public.chat_messages.id;


--
-- Name: competencies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.competencies (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    grade_id bigint,
    subject_id bigint,
    name character varying NOT NULL,
    code character varying,
    domain character varying,
    description text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: competencies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.competencies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: competencies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.competencies_id_seq OWNED BY public.competencies.id;


--
-- Name: competency_scores; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.competency_scores (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    competency_id bigint NOT NULL,
    student_id bigint NOT NULL,
    assessed_by_id bigint,
    term character varying NOT NULL,
    level character varying NOT NULL,
    remarks text,
    assessed_on date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: competency_scores_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.competency_scores_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: competency_scores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.competency_scores_id_seq OWNED BY public.competency_scores.id;


--
-- Name: conversations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.conversations (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    student_id bigint,
    staff_id bigint NOT NULL,
    guardian_id bigint,
    subject character varying,
    last_message_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: conversations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.conversations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: conversations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.conversations_id_seq OWNED BY public.conversations.id;


--
-- Name: departments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.departments (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    name character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: departments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.departments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: departments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.departments_id_seq OWNED BY public.departments.id;


--
-- Name: enrollments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.enrollments (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    academic_year_id bigint NOT NULL,
    student_id bigint NOT NULL,
    section_id bigint NOT NULL,
    roll_no character varying,
    status character varying DEFAULT 'active'::character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: enrollments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.enrollments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: enrollments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.enrollments_id_seq OWNED BY public.enrollments.id;


--
-- Name: evaluations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.evaluations (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    exam_schedule_id bigint NOT NULL,
    student_id bigint NOT NULL,
    evaluator_id bigint,
    marks numeric(6,2),
    status character varying DEFAULT 'pending'::character varying NOT NULL,
    remarks text,
    evaluated_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: evaluations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.evaluations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: evaluations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.evaluations_id_seq OWNED BY public.evaluations.id;


--
-- Name: exam_results; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.exam_results (
    id bigint NOT NULL,
    exam_schedule_id bigint NOT NULL,
    student_id bigint NOT NULL,
    marks numeric(6,2),
    grade character varying,
    absent boolean DEFAULT false NOT NULL,
    remarks character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: exam_results_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.exam_results_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: exam_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.exam_results_id_seq OWNED BY public.exam_results.id;


--
-- Name: exam_schedules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.exam_schedules (
    id bigint NOT NULL,
    exam_id bigint NOT NULL,
    section_id bigint NOT NULL,
    subject_id bigint NOT NULL,
    on_date date,
    starts_at time without time zone,
    ends_at time without time zone,
    max_marks numeric(6,2) DEFAULT 100.0 NOT NULL,
    pass_marks numeric(6,2) DEFAULT 33.0 NOT NULL,
    room character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: exam_schedules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.exam_schedules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: exam_schedules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.exam_schedules_id_seq OWNED BY public.exam_schedules.id;


--
-- Name: exams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.exams (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    academic_year_id bigint NOT NULL,
    name character varying NOT NULL,
    exam_type character varying DEFAULT 'term'::character varying NOT NULL,
    starts_on date,
    ends_on date,
    published boolean DEFAULT false NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: exams_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.exams_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: exams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.exams_id_seq OWNED BY public.exams.id;


--
-- Name: fee_heads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fee_heads (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    name character varying NOT NULL,
    code character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: fee_heads_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.fee_heads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fee_heads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.fee_heads_id_seq OWNED BY public.fee_heads.id;


--
-- Name: fee_invoice_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fee_invoice_items (
    id bigint NOT NULL,
    fee_invoice_id bigint NOT NULL,
    fee_head_id bigint,
    description character varying NOT NULL,
    amount numeric(12,2) NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: fee_invoice_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.fee_invoice_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fee_invoice_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.fee_invoice_items_id_seq OWNED BY public.fee_invoice_items.id;


--
-- Name: fee_invoices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fee_invoices (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    academic_year_id bigint NOT NULL,
    student_id bigint NOT NULL,
    number character varying NOT NULL,
    period character varying,
    issue_date date NOT NULL,
    due_date date NOT NULL,
    total numeric(12,2) DEFAULT 0.0 NOT NULL,
    discount numeric(12,2) DEFAULT 0.0 NOT NULL,
    fine numeric(12,2) DEFAULT 0.0 NOT NULL,
    paid numeric(12,2) DEFAULT 0.0 NOT NULL,
    status character varying DEFAULT 'unpaid'::character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: fee_invoices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.fee_invoices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fee_invoices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.fee_invoices_id_seq OWNED BY public.fee_invoices.id;


--
-- Name: fee_payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fee_payments (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    fee_invoice_id bigint NOT NULL,
    received_by_id bigint,
    amount numeric(12,2) NOT NULL,
    method character varying DEFAULT 'cash'::character varying NOT NULL,
    reference character varying,
    gateway character varying,
    gateway_ref character varying,
    status character varying DEFAULT 'success'::character varying NOT NULL,
    paid_at timestamp(6) without time zone NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: fee_payments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.fee_payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fee_payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.fee_payments_id_seq OWNED BY public.fee_payments.id;


--
-- Name: fee_structures; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fee_structures (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    academic_year_id bigint NOT NULL,
    grade_id bigint NOT NULL,
    fee_head_id bigint NOT NULL,
    amount numeric(12,2) NOT NULL,
    frequency character varying DEFAULT 'monthly'::character varying NOT NULL,
    due_day integer DEFAULT 10 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: fee_structures_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.fee_structures_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fee_structures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.fee_structures_id_seq OWNED BY public.fee_structures.id;


--
-- Name: gate_passes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gate_passes (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    student_id bigint,
    staff_id bigint,
    approved_by_id bigint,
    reason character varying NOT NULL,
    out_at timestamp(6) without time zone NOT NULL,
    in_at timestamp(6) without time zone,
    status character varying DEFAULT 'pending'::character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: gate_passes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.gate_passes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gate_passes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.gate_passes_id_seq OWNED BY public.gate_passes.id;


--
-- Name: grades; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.grades (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    name character varying NOT NULL,
    level integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: grades_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.grades_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: grades_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.grades_id_seq OWNED BY public.grades.id;


--
-- Name: greeting_campaigns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.greeting_campaigns (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    title character varying NOT NULL,
    occasion character varying DEFAULT 'birthday'::character varying NOT NULL,
    audience character varying DEFAULT 'students'::character varying NOT NULL,
    message text,
    background_color character varying DEFAULT '#4f46e5'::character varying NOT NULL,
    automatic boolean DEFAULT true NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: greeting_campaigns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.greeting_campaigns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: greeting_campaigns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.greeting_campaigns_id_seq OWNED BY public.greeting_campaigns.id;


--
-- Name: guardians; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.guardians (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    user_id bigint,
    name character varying NOT NULL,
    relation character varying,
    phone character varying,
    email character varying,
    occupation character varying,
    address text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: guardians_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.guardians_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: guardians_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.guardians_id_seq OWNED BY public.guardians.id;


--
-- Name: guardianships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.guardianships (
    id bigint NOT NULL,
    guardian_id bigint NOT NULL,
    student_id bigint NOT NULL,
    primary_contact boolean DEFAULT false NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: guardianships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.guardianships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: guardianships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.guardianships_id_seq OWNED BY public.guardianships.id;


--
-- Name: health_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.health_records (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    student_id bigint NOT NULL,
    checked_on date NOT NULL,
    height_cm numeric(5,1),
    weight_kg numeric(5,1),
    blood_pressure character varying,
    pulse integer,
    vision character varying,
    allergies text,
    notes text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: health_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.health_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: health_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.health_records_id_seq OWNED BY public.health_records.id;


--
-- Name: homework_submissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.homework_submissions (
    id bigint NOT NULL,
    homework_id bigint NOT NULL,
    student_id bigint NOT NULL,
    content text,
    submitted_at timestamp(6) without time zone,
    status character varying DEFAULT 'pending'::character varying NOT NULL,
    marks numeric(6,2),
    feedback character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: homework_submissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.homework_submissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: homework_submissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.homework_submissions_id_seq OWNED BY public.homework_submissions.id;


--
-- Name: homeworks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.homeworks (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    section_id bigint NOT NULL,
    subject_id bigint,
    staff_id bigint,
    title character varying NOT NULL,
    description text,
    assigned_on date NOT NULL,
    due_on date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: homeworks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.homeworks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: homeworks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.homeworks_id_seq OWNED BY public.homeworks.id;


--
-- Name: hostel_allocations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hostel_allocations (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    hostel_room_id bigint NOT NULL,
    student_id bigint NOT NULL,
    from_on date NOT NULL,
    to_on date,
    bed_no character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: hostel_allocations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.hostel_allocations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hostel_allocations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.hostel_allocations_id_seq OWNED BY public.hostel_allocations.id;


--
-- Name: hostel_rooms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hostel_rooms (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    hostel_id bigint NOT NULL,
    number character varying NOT NULL,
    kind character varying DEFAULT 'shared'::character varying NOT NULL,
    capacity integer DEFAULT 2 NOT NULL,
    rent numeric(10,2) DEFAULT 0.0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: hostel_rooms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.hostel_rooms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hostel_rooms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.hostel_rooms_id_seq OWNED BY public.hostel_rooms.id;


--
-- Name: hostels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hostels (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    warden_id bigint,
    name character varying NOT NULL,
    kind character varying DEFAULT 'boys'::character varying NOT NULL,
    address text,
    capacity integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: hostels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.hostels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hostels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.hostels_id_seq OWNED BY public.hostels.id;


--
-- Name: id_card_templates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.id_card_templates (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    name character varying NOT NULL,
    audience character varying DEFAULT 'student'::character varying NOT NULL,
    orientation character varying DEFAULT 'portrait'::character varying NOT NULL,
    background_color character varying DEFAULT '#4f46e5'::character varying NOT NULL,
    fields jsonb DEFAULT '[]'::jsonb NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: id_card_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.id_card_templates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: id_card_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.id_card_templates_id_seq OWNED BY public.id_card_templates.id;


--
-- Name: inventory_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inventory_items (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    name character varying NOT NULL,
    code character varying,
    category character varying,
    unit character varying DEFAULT 'pcs'::character varying NOT NULL,
    quantity integer DEFAULT 0 NOT NULL,
    reorder_level integer DEFAULT 0 NOT NULL,
    unit_cost numeric(10,2),
    store character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: inventory_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.inventory_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inventory_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.inventory_items_id_seq OWNED BY public.inventory_items.id;


--
-- Name: issued_certificates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.issued_certificates (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    certificate_template_id bigint NOT NULL,
    student_id bigint NOT NULL,
    issued_by_id bigint,
    number character varying NOT NULL,
    issued_on date NOT NULL,
    remarks text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: issued_certificates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.issued_certificates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: issued_certificates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.issued_certificates_id_seq OWNED BY public.issued_certificates.id;


--
-- Name: kb_articles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.kb_articles (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    title character varying NOT NULL,
    category character varying,
    body text NOT NULL,
    audience character varying DEFAULT 'all'::character varying NOT NULL,
    published boolean DEFAULT true NOT NULL,
    views integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: kb_articles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.kb_articles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: kb_articles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.kb_articles_id_seq OWNED BY public.kb_articles.id;


--
-- Name: ledger_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ledger_entries (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    recorded_by_id bigint,
    direction character varying DEFAULT 'expense'::character varying NOT NULL,
    category character varying,
    description character varying NOT NULL,
    amount numeric(12,2) NOT NULL,
    on_date date NOT NULL,
    payment_mode character varying DEFAULT 'cash'::character varying NOT NULL,
    reference character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ledger_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ledger_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ledger_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ledger_entries_id_seq OWNED BY public.ledger_entries.id;


--
-- Name: lesson_plans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lesson_plans (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    section_id bigint,
    subject_id bigint,
    staff_id bigint,
    week_of date NOT NULL,
    topic character varying NOT NULL,
    objectives text,
    activities text,
    resources text,
    status character varying DEFAULT 'planned'::character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: lesson_plans_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lesson_plans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lesson_plans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lesson_plans_id_seq OWNED BY public.lesson_plans.id;


--
-- Name: live_classes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.live_classes (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    section_id bigint,
    subject_id bigint,
    staff_id bigint,
    title character varying NOT NULL,
    starts_at timestamp(6) without time zone NOT NULL,
    duration_minutes integer DEFAULT 45 NOT NULL,
    platform character varying DEFAULT 'meet'::character varying NOT NULL,
    join_url character varying,
    status character varying DEFAULT 'scheduled'::character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: live_classes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.live_classes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: live_classes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.live_classes_id_seq OWNED BY public.live_classes.id;


--
-- Name: message_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.message_logs (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    message_template_id bigint,
    sent_by_id bigint,
    channel character varying DEFAULT 'sms'::character varying NOT NULL,
    audience character varying DEFAULT 'all'::character varying NOT NULL,
    recipient character varying,
    subject character varying,
    body text NOT NULL,
    status character varying DEFAULT 'queued'::character varying NOT NULL,
    recipient_count integer DEFAULT 1 NOT NULL,
    sent_at timestamp(6) without time zone,
    error character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: message_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.message_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: message_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.message_logs_id_seq OWNED BY public.message_logs.id;


--
-- Name: message_templates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.message_templates (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    name character varying NOT NULL,
    channel character varying DEFAULT 'sms'::character varying NOT NULL,
    subject character varying,
    body text NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: message_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.message_templates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: message_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.message_templates_id_seq OWNED BY public.message_templates.id;


--
-- Name: notices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notices (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    section_id bigint,
    created_by_id bigint,
    title character varying NOT NULL,
    body text,
    audience character varying DEFAULT 'all'::character varying NOT NULL,
    published_at timestamp(6) without time zone,
    expires_on date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: notices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notices_id_seq OWNED BY public.notices.id;


--
-- Name: online_tests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.online_tests (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    academic_year_id bigint,
    subject_id bigint,
    grade_id bigint,
    staff_id bigint,
    name character varying NOT NULL,
    instructions text,
    duration_minutes integer DEFAULT 30 NOT NULL,
    opens_at timestamp(6) without time zone,
    closes_at timestamp(6) without time zone,
    total_marks numeric(6,2) DEFAULT 0.0 NOT NULL,
    pass_marks numeric(6,2) DEFAULT 0.0 NOT NULL,
    shuffle_questions boolean DEFAULT true NOT NULL,
    status character varying DEFAULT 'draft'::character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: online_tests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.online_tests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: online_tests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.online_tests_id_seq OWNED BY public.online_tests.id;


--
-- Name: payslips; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payslips (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    staff_id bigint NOT NULL,
    period character varying NOT NULL,
    basic numeric(12,2) DEFAULT 0.0 NOT NULL,
    allowances numeric(12,2) DEFAULT 0.0 NOT NULL,
    deductions numeric(12,2) DEFAULT 0.0 NOT NULL,
    net_pay numeric(12,2) DEFAULT 0.0 NOT NULL,
    days_present integer,
    status character varying DEFAULT 'draft'::character varying NOT NULL,
    paid_on date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: payslips_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.payslips_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payslips_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.payslips_id_seq OWNED BY public.payslips.id;


--
-- Name: phone_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.phone_logs (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    caller_name character varying,
    phone character varying,
    direction character varying DEFAULT 'incoming'::character varying NOT NULL,
    purpose character varying,
    called_at timestamp(6) without time zone NOT NULL,
    notes text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: phone_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.phone_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: phone_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.phone_logs_id_seq OWNED BY public.phone_logs.id;


--
-- Name: postal_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.postal_records (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    direction character varying DEFAULT 'received'::character varying NOT NULL,
    reference_no character varying,
    from_name character varying,
    to_name character varying,
    on_date date NOT NULL,
    notes text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: postal_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.postal_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: postal_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.postal_records_id_seq OWNED BY public.postal_records.id;


--
-- Name: ptm_meetings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ptm_meetings (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    section_id bigint,
    title character varying NOT NULL,
    on_date date NOT NULL,
    starts_at time without time zone,
    ends_at time without time zone,
    slot_minutes integer DEFAULT 15 NOT NULL,
    venue character varying,
    status character varying DEFAULT 'scheduled'::character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ptm_meetings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ptm_meetings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ptm_meetings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ptm_meetings_id_seq OWNED BY public.ptm_meetings.id;


--
-- Name: ptm_slots; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ptm_slots (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    ptm_meeting_id bigint NOT NULL,
    staff_id bigint,
    student_id bigint,
    starts_at time without time zone NOT NULL,
    status character varying DEFAULT 'open'::character varying NOT NULL,
    remarks text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ptm_slots_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ptm_slots_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ptm_slots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ptm_slots_id_seq OWNED BY public.ptm_slots.id;


--
-- Name: role_assignments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.role_assignments (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    role_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: role_assignments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.role_assignments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: role_assignments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.role_assignments_id_seq OWNED BY public.role_assignments.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id bigint NOT NULL,
    school_id bigint,
    name character varying NOT NULL,
    permissions character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    system boolean DEFAULT false NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: route_stops; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.route_stops (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    transport_route_id bigint NOT NULL,
    name character varying NOT NULL,
    pickup_at time without time zone,
    drop_at time without time zone,
    latitude numeric(10,6),
    longitude numeric(10,6),
    "position" integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: route_stops_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.route_stops_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: route_stops_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.route_stops_id_seq OWNED BY public.route_stops.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: schools; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schools (
    id bigint NOT NULL,
    name character varying NOT NULL,
    code character varying NOT NULL,
    subdomain character varying NOT NULL,
    email character varying,
    phone character varying,
    website character varying,
    address text,
    city character varying,
    state character varying,
    country character varying DEFAULT 'IN'::character varying,
    postcode character varying,
    timezone character varying DEFAULT 'Asia/Kolkata'::character varying NOT NULL,
    currency character varying DEFAULT 'INR'::character varying NOT NULL,
    locale character varying DEFAULT 'en'::character varying NOT NULL,
    theme character varying DEFAULT 'default'::character varying NOT NULL,
    primary_color character varying DEFAULT '#4f46e5'::character varying NOT NULL,
    enabled_modules character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    settings jsonb DEFAULT '{}'::jsonb NOT NULL,
    active boolean DEFAULT true NOT NULL,
    subscription_ends_on date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: schools_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.schools_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: schools_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.schools_id_seq OWNED BY public.schools.id;


--
-- Name: sections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sections (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    grade_id bigint NOT NULL,
    class_teacher_id bigint,
    name character varying NOT NULL,
    capacity integer DEFAULT 40 NOT NULL,
    room character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: sections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sections_id_seq OWNED BY public.sections.id;


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    ip_address character varying,
    user_agent character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sessions_id_seq OWNED BY public.sessions.id;


--
-- Name: staffs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.staffs (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    user_id bigint,
    department_id bigint,
    employee_no character varying NOT NULL,
    first_name character varying NOT NULL,
    last_name character varying,
    designation character varying,
    joining_date date,
    date_of_birth date,
    gender character varying,
    phone character varying,
    email character varying,
    qualification character varying,
    address text,
    basic_salary numeric(12,2),
    biometric_id character varying,
    status character varying DEFAULT 'active'::character varying NOT NULL,
    custom_fields jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: staffs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.staffs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: staffs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.staffs_id_seq OWNED BY public.staffs.id;


--
-- Name: stock_movements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stock_movements (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    inventory_item_id bigint NOT NULL,
    recorded_by_id bigint,
    direction character varying DEFAULT 'in'::character varying NOT NULL,
    quantity integer NOT NULL,
    reason character varying,
    on_date date NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: stock_movements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stock_movements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stock_movements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stock_movements_id_seq OWNED BY public.stock_movements.id;


--
-- Name: students; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.students (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    user_id bigint,
    admission_no character varying NOT NULL,
    first_name character varying NOT NULL,
    last_name character varying,
    date_of_birth date,
    gender character varying,
    blood_group character varying,
    phone character varying,
    email character varying,
    address text,
    admission_date date,
    status character varying DEFAULT 'active'::character varying NOT NULL,
    house character varying,
    religion character varying,
    category character varying,
    national_id character varying,
    biometric_id character varying,
    previous_school character varying,
    notes text,
    custom_fields jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: students_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.students_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: students_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.students_id_seq OWNED BY public.students.id;


--
-- Name: study_materials; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.study_materials (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    grade_id bigint,
    subject_id bigint,
    staff_id bigint,
    title character varying NOT NULL,
    kind character varying DEFAULT 'notes'::character varying NOT NULL,
    url character varying,
    description text,
    published boolean DEFAULT true NOT NULL,
    downloads integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: study_materials_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.study_materials_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: study_materials_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.study_materials_id_seq OWNED BY public.study_materials.id;


--
-- Name: subject_assignments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subject_assignments (
    id bigint NOT NULL,
    section_id bigint NOT NULL,
    subject_id bigint NOT NULL,
    staff_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: subject_assignments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.subject_assignments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subject_assignments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.subject_assignments_id_seq OWNED BY public.subject_assignments.id;


--
-- Name: subjects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subjects (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    grade_id bigint,
    name character varying NOT NULL,
    code character varying,
    subject_type character varying DEFAULT 'theory'::character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: subjects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.subjects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subjects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.subjects_id_seq OWNED BY public.subjects.id;


--
-- Name: survey_questions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.survey_questions (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    survey_id bigint NOT NULL,
    prompt character varying NOT NULL,
    kind character varying DEFAULT 'rating'::character varying NOT NULL,
    choices character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    "position" integer DEFAULT 0 NOT NULL,
    required boolean DEFAULT true NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: survey_questions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.survey_questions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: survey_questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.survey_questions_id_seq OWNED BY public.survey_questions.id;


--
-- Name: survey_responses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.survey_responses (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    survey_question_id bigint NOT NULL,
    user_id bigint,
    rating integer,
    choice character varying,
    answer text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: survey_responses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.survey_responses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: survey_responses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.survey_responses_id_seq OWNED BY public.survey_responses.id;


--
-- Name: surveys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.surveys (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    title character varying NOT NULL,
    description text,
    audience character varying DEFAULT 'parents'::character varying NOT NULL,
    opens_on date,
    closes_on date,
    anonymous boolean DEFAULT false NOT NULL,
    status character varying DEFAULT 'draft'::character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: surveys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.surveys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: surveys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.surveys_id_seq OWNED BY public.surveys.id;


--
-- Name: test_attempts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.test_attempts (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    online_test_id bigint NOT NULL,
    student_id bigint NOT NULL,
    started_at timestamp(6) without time zone,
    submitted_at timestamp(6) without time zone,
    score numeric(6,2),
    status character varying DEFAULT 'in_progress'::character varying NOT NULL,
    answers jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: test_attempts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.test_attempts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: test_attempts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.test_attempts_id_seq OWNED BY public.test_attempts.id;


--
-- Name: test_questions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.test_questions (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    online_test_id bigint NOT NULL,
    prompt text NOT NULL,
    kind character varying DEFAULT 'mcq'::character varying NOT NULL,
    options character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    answer character varying,
    marks numeric(6,2) DEFAULT 1.0 NOT NULL,
    "position" integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: test_questions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.test_questions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: test_questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.test_questions_id_seq OWNED BY public.test_questions.id;


--
-- Name: timetable_slots; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.timetable_slots (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    academic_year_id bigint NOT NULL,
    section_id bigint NOT NULL,
    subject_id bigint,
    staff_id bigint,
    weekday integer NOT NULL,
    starts_at time without time zone NOT NULL,
    ends_at time without time zone NOT NULL,
    room character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: timetable_slots_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.timetable_slots_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: timetable_slots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.timetable_slots_id_seq OWNED BY public.timetable_slots.id;


--
-- Name: transport_assignments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transport_assignments (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    student_id bigint NOT NULL,
    transport_route_id bigint NOT NULL,
    route_stop_id bigint,
    direction character varying DEFAULT 'both'::character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: transport_assignments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.transport_assignments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transport_assignments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.transport_assignments_id_seq OWNED BY public.transport_assignments.id;


--
-- Name: transport_routes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transport_routes (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    vehicle_id bigint,
    name character varying NOT NULL,
    start_point character varying,
    end_point character varying,
    fare numeric(10,2) DEFAULT 0.0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: transport_routes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.transport_routes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transport_routes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.transport_routes_id_seq OWNED BY public.transport_routes.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    school_id bigint,
    email_address character varying NOT NULL,
    password_digest character varying NOT NULL,
    name character varying NOT NULL,
    phone character varying,
    kind character varying DEFAULT 'staff'::character varying NOT NULL,
    active boolean DEFAULT true NOT NULL,
    locale character varying,
    last_seen_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: vehicle_locations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vehicle_locations (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    vehicle_id bigint NOT NULL,
    latitude numeric(10,6) NOT NULL,
    longitude numeric(10,6) NOT NULL,
    speed numeric(6,2),
    heading integer,
    recorded_at timestamp(6) without time zone NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: vehicle_locations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vehicle_locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vehicle_locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vehicle_locations_id_seq OWNED BY public.vehicle_locations.id;


--
-- Name: vehicles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vehicles (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    driver_id bigint,
    registration_no character varying NOT NULL,
    model character varying,
    capacity integer DEFAULT 40 NOT NULL,
    gps_device_id character varying,
    insurance_expires_on date,
    fitness_expires_on date,
    status character varying DEFAULT 'active'::character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: vehicles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vehicles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vehicles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vehicles_id_seq OWNED BY public.vehicles.id;


--
-- Name: visitors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.visitors (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    meeting_id bigint,
    name character varying NOT NULL,
    phone character varying,
    purpose character varying,
    pass_no character varying,
    party_size integer DEFAULT 1 NOT NULL,
    in_at timestamp(6) without time zone NOT NULL,
    out_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: visitors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.visitors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: visitors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.visitors_id_seq OWNED BY public.visitors.id;


--
-- Name: web_pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.web_pages (
    id bigint NOT NULL,
    school_id bigint NOT NULL,
    title character varying NOT NULL,
    slug character varying NOT NULL,
    body text,
    section character varying DEFAULT 'page'::character varying NOT NULL,
    "position" integer DEFAULT 0 NOT NULL,
    published boolean DEFAULT false NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: web_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.web_pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: web_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.web_pages_id_seq OWNED BY public.web_pages.id;


--
-- Name: academic_years id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.academic_years ALTER COLUMN id SET DEFAULT nextval('public.academic_years_id_seq'::regclass);


--
-- Name: admission_enquiries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admission_enquiries ALTER COLUMN id SET DEFAULT nextval('public.admission_enquiries_id_seq'::regclass);


--
-- Name: assets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assets ALTER COLUMN id SET DEFAULT nextval('public.assets_id_seq'::regclass);


--
-- Name: attendances id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendances ALTER COLUMN id SET DEFAULT nextval('public.attendances_id_seq'::regclass);


--
-- Name: biometric_devices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.biometric_devices ALTER COLUMN id SET DEFAULT nextval('public.biometric_devices_id_seq'::regclass);


--
-- Name: biometric_punches id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.biometric_punches ALTER COLUMN id SET DEFAULT nextval('public.biometric_punches_id_seq'::regclass);


--
-- Name: book_issues id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.book_issues ALTER COLUMN id SET DEFAULT nextval('public.book_issues_id_seq'::regclass);


--
-- Name: books id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.books ALTER COLUMN id SET DEFAULT nextval('public.books_id_seq'::regclass);


--
-- Name: cameras id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cameras ALTER COLUMN id SET DEFAULT nextval('public.cameras_id_seq'::regclass);


--
-- Name: campus_workers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campus_workers ALTER COLUMN id SET DEFAULT nextval('public.campus_workers_id_seq'::regclass);


--
-- Name: certificate_templates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certificate_templates ALTER COLUMN id SET DEFAULT nextval('public.certificate_templates_id_seq'::regclass);


--
-- Name: chat_messages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chat_messages ALTER COLUMN id SET DEFAULT nextval('public.chat_messages_id_seq'::regclass);


--
-- Name: competencies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competencies ALTER COLUMN id SET DEFAULT nextval('public.competencies_id_seq'::regclass);


--
-- Name: competency_scores id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competency_scores ALTER COLUMN id SET DEFAULT nextval('public.competency_scores_id_seq'::regclass);


--
-- Name: conversations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversations ALTER COLUMN id SET DEFAULT nextval('public.conversations_id_seq'::regclass);


--
-- Name: departments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departments ALTER COLUMN id SET DEFAULT nextval('public.departments_id_seq'::regclass);


--
-- Name: enrollments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enrollments ALTER COLUMN id SET DEFAULT nextval('public.enrollments_id_seq'::regclass);


--
-- Name: evaluations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.evaluations ALTER COLUMN id SET DEFAULT nextval('public.evaluations_id_seq'::regclass);


--
-- Name: exam_results id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exam_results ALTER COLUMN id SET DEFAULT nextval('public.exam_results_id_seq'::regclass);


--
-- Name: exam_schedules id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exam_schedules ALTER COLUMN id SET DEFAULT nextval('public.exam_schedules_id_seq'::regclass);


--
-- Name: exams id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exams ALTER COLUMN id SET DEFAULT nextval('public.exams_id_seq'::regclass);


--
-- Name: fee_heads id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fee_heads ALTER COLUMN id SET DEFAULT nextval('public.fee_heads_id_seq'::regclass);


--
-- Name: fee_invoice_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fee_invoice_items ALTER COLUMN id SET DEFAULT nextval('public.fee_invoice_items_id_seq'::regclass);


--
-- Name: fee_invoices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fee_invoices ALTER COLUMN id SET DEFAULT nextval('public.fee_invoices_id_seq'::regclass);


--
-- Name: fee_payments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fee_payments ALTER COLUMN id SET DEFAULT nextval('public.fee_payments_id_seq'::regclass);


--
-- Name: fee_structures id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fee_structures ALTER COLUMN id SET DEFAULT nextval('public.fee_structures_id_seq'::regclass);


--
-- Name: gate_passes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gate_passes ALTER COLUMN id SET DEFAULT nextval('public.gate_passes_id_seq'::regclass);


--
-- Name: grades id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grades ALTER COLUMN id SET DEFAULT nextval('public.grades_id_seq'::regclass);


--
-- Name: greeting_campaigns id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.greeting_campaigns ALTER COLUMN id SET DEFAULT nextval('public.greeting_campaigns_id_seq'::regclass);


--
-- Name: guardians id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guardians ALTER COLUMN id SET DEFAULT nextval('public.guardians_id_seq'::regclass);


--
-- Name: guardianships id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guardianships ALTER COLUMN id SET DEFAULT nextval('public.guardianships_id_seq'::regclass);


--
-- Name: health_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.health_records ALTER COLUMN id SET DEFAULT nextval('public.health_records_id_seq'::regclass);


--
-- Name: homework_submissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.homework_submissions ALTER COLUMN id SET DEFAULT nextval('public.homework_submissions_id_seq'::regclass);


--
-- Name: homeworks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.homeworks ALTER COLUMN id SET DEFAULT nextval('public.homeworks_id_seq'::regclass);


--
-- Name: hostel_allocations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hostel_allocations ALTER COLUMN id SET DEFAULT nextval('public.hostel_allocations_id_seq'::regclass);


--
-- Name: hostel_rooms id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hostel_rooms ALTER COLUMN id SET DEFAULT nextval('public.hostel_rooms_id_seq'::regclass);


--
-- Name: hostels id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hostels ALTER COLUMN id SET DEFAULT nextval('public.hostels_id_seq'::regclass);


--
-- Name: id_card_templates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.id_card_templates ALTER COLUMN id SET DEFAULT nextval('public.id_card_templates_id_seq'::regclass);


--
-- Name: inventory_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_items ALTER COLUMN id SET DEFAULT nextval('public.inventory_items_id_seq'::regclass);


--
-- Name: issued_certificates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.issued_certificates ALTER COLUMN id SET DEFAULT nextval('public.issued_certificates_id_seq'::regclass);


--
-- Name: kb_articles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kb_articles ALTER COLUMN id SET DEFAULT nextval('public.kb_articles_id_seq'::regclass);


--
-- Name: ledger_entries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ledger_entries ALTER COLUMN id SET DEFAULT nextval('public.ledger_entries_id_seq'::regclass);


--
-- Name: lesson_plans id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lesson_plans ALTER COLUMN id SET DEFAULT nextval('public.lesson_plans_id_seq'::regclass);


--
-- Name: live_classes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.live_classes ALTER COLUMN id SET DEFAULT nextval('public.live_classes_id_seq'::regclass);


--
-- Name: message_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.message_logs ALTER COLUMN id SET DEFAULT nextval('public.message_logs_id_seq'::regclass);


--
-- Name: message_templates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.message_templates ALTER COLUMN id SET DEFAULT nextval('public.message_templates_id_seq'::regclass);


--
-- Name: notices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notices ALTER COLUMN id SET DEFAULT nextval('public.notices_id_seq'::regclass);


--
-- Name: online_tests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.online_tests ALTER COLUMN id SET DEFAULT nextval('public.online_tests_id_seq'::regclass);


--
-- Name: payslips id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payslips ALTER COLUMN id SET DEFAULT nextval('public.payslips_id_seq'::regclass);


--
-- Name: phone_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.phone_logs ALTER COLUMN id SET DEFAULT nextval('public.phone_logs_id_seq'::regclass);


--
-- Name: postal_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.postal_records ALTER COLUMN id SET DEFAULT nextval('public.postal_records_id_seq'::regclass);


--
-- Name: ptm_meetings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ptm_meetings ALTER COLUMN id SET DEFAULT nextval('public.ptm_meetings_id_seq'::regclass);


--
-- Name: ptm_slots id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ptm_slots ALTER COLUMN id SET DEFAULT nextval('public.ptm_slots_id_seq'::regclass);


--
-- Name: role_assignments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_assignments ALTER COLUMN id SET DEFAULT nextval('public.role_assignments_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: route_stops id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.route_stops ALTER COLUMN id SET DEFAULT nextval('public.route_stops_id_seq'::regclass);


--
-- Name: schools id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schools ALTER COLUMN id SET DEFAULT nextval('public.schools_id_seq'::regclass);


--
-- Name: sections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sections ALTER COLUMN id SET DEFAULT nextval('public.sections_id_seq'::regclass);


--
-- Name: sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions ALTER COLUMN id SET DEFAULT nextval('public.sessions_id_seq'::regclass);


--
-- Name: staffs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staffs ALTER COLUMN id SET DEFAULT nextval('public.staffs_id_seq'::regclass);


--
-- Name: stock_movements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_movements ALTER COLUMN id SET DEFAULT nextval('public.stock_movements_id_seq'::regclass);


--
-- Name: students id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.students ALTER COLUMN id SET DEFAULT nextval('public.students_id_seq'::regclass);


--
-- Name: study_materials id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.study_materials ALTER COLUMN id SET DEFAULT nextval('public.study_materials_id_seq'::regclass);


--
-- Name: subject_assignments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subject_assignments ALTER COLUMN id SET DEFAULT nextval('public.subject_assignments_id_seq'::regclass);


--
-- Name: subjects id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subjects ALTER COLUMN id SET DEFAULT nextval('public.subjects_id_seq'::regclass);


--
-- Name: survey_questions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_questions ALTER COLUMN id SET DEFAULT nextval('public.survey_questions_id_seq'::regclass);


--
-- Name: survey_responses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_responses ALTER COLUMN id SET DEFAULT nextval('public.survey_responses_id_seq'::regclass);


--
-- Name: surveys id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.surveys ALTER COLUMN id SET DEFAULT nextval('public.surveys_id_seq'::regclass);


--
-- Name: test_attempts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_attempts ALTER COLUMN id SET DEFAULT nextval('public.test_attempts_id_seq'::regclass);


--
-- Name: test_questions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_questions ALTER COLUMN id SET DEFAULT nextval('public.test_questions_id_seq'::regclass);


--
-- Name: timetable_slots id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.timetable_slots ALTER COLUMN id SET DEFAULT nextval('public.timetable_slots_id_seq'::regclass);


--
-- Name: transport_assignments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transport_assignments ALTER COLUMN id SET DEFAULT nextval('public.transport_assignments_id_seq'::regclass);


--
-- Name: transport_routes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transport_routes ALTER COLUMN id SET DEFAULT nextval('public.transport_routes_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: vehicle_locations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicle_locations ALTER COLUMN id SET DEFAULT nextval('public.vehicle_locations_id_seq'::regclass);


--
-- Name: vehicles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicles ALTER COLUMN id SET DEFAULT nextval('public.vehicles_id_seq'::regclass);


--
-- Name: visitors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visitors ALTER COLUMN id SET DEFAULT nextval('public.visitors_id_seq'::regclass);


--
-- Name: web_pages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.web_pages ALTER COLUMN id SET DEFAULT nextval('public.web_pages_id_seq'::regclass);


--
-- Name: academic_years academic_years_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.academic_years
    ADD CONSTRAINT academic_years_pkey PRIMARY KEY (id);


--
-- Name: admission_enquiries admission_enquiries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admission_enquiries
    ADD CONSTRAINT admission_enquiries_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: assets assets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assets
    ADD CONSTRAINT assets_pkey PRIMARY KEY (id);


--
-- Name: attendances attendances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendances
    ADD CONSTRAINT attendances_pkey PRIMARY KEY (id);


--
-- Name: biometric_devices biometric_devices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.biometric_devices
    ADD CONSTRAINT biometric_devices_pkey PRIMARY KEY (id);


--
-- Name: biometric_punches biometric_punches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.biometric_punches
    ADD CONSTRAINT biometric_punches_pkey PRIMARY KEY (id);


--
-- Name: book_issues book_issues_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.book_issues
    ADD CONSTRAINT book_issues_pkey PRIMARY KEY (id);


--
-- Name: books books_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.books
    ADD CONSTRAINT books_pkey PRIMARY KEY (id);


--
-- Name: cameras cameras_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cameras
    ADD CONSTRAINT cameras_pkey PRIMARY KEY (id);


--
-- Name: campus_workers campus_workers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campus_workers
    ADD CONSTRAINT campus_workers_pkey PRIMARY KEY (id);


--
-- Name: certificate_templates certificate_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certificate_templates
    ADD CONSTRAINT certificate_templates_pkey PRIMARY KEY (id);


--
-- Name: chat_messages chat_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_pkey PRIMARY KEY (id);


--
-- Name: competencies competencies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competencies
    ADD CONSTRAINT competencies_pkey PRIMARY KEY (id);


--
-- Name: competency_scores competency_scores_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competency_scores
    ADD CONSTRAINT competency_scores_pkey PRIMARY KEY (id);


--
-- Name: conversations conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversations_pkey PRIMARY KEY (id);


--
-- Name: departments departments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (id);


--
-- Name: enrollments enrollments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT enrollments_pkey PRIMARY KEY (id);


--
-- Name: evaluations evaluations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.evaluations
    ADD CONSTRAINT evaluations_pkey PRIMARY KEY (id);


--
-- Name: exam_results exam_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exam_results
    ADD CONSTRAINT exam_results_pkey PRIMARY KEY (id);


--
-- Name: exam_schedules exam_schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exam_schedules
    ADD CONSTRAINT exam_schedules_pkey PRIMARY KEY (id);


--
-- Name: exams exams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exams
    ADD CONSTRAINT exams_pkey PRIMARY KEY (id);


--
-- Name: fee_heads fee_heads_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fee_heads
    ADD CONSTRAINT fee_heads_pkey PRIMARY KEY (id);


--
-- Name: fee_invoice_items fee_invoice_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fee_invoice_items
    ADD CONSTRAINT fee_invoice_items_pkey PRIMARY KEY (id);


--
-- Name: fee_invoices fee_invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fee_invoices
    ADD CONSTRAINT fee_invoices_pkey PRIMARY KEY (id);


--
-- Name: fee_payments fee_payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fee_payments
    ADD CONSTRAINT fee_payments_pkey PRIMARY KEY (id);


--
-- Name: fee_structures fee_structures_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fee_structures
    ADD CONSTRAINT fee_structures_pkey PRIMARY KEY (id);


--
-- Name: gate_passes gate_passes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gate_passes
    ADD CONSTRAINT gate_passes_pkey PRIMARY KEY (id);


--
-- Name: grades grades_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grades
    ADD CONSTRAINT grades_pkey PRIMARY KEY (id);


--
-- Name: greeting_campaigns greeting_campaigns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.greeting_campaigns
    ADD CONSTRAINT greeting_campaigns_pkey PRIMARY KEY (id);


--
-- Name: guardians guardians_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guardians
    ADD CONSTRAINT guardians_pkey PRIMARY KEY (id);


--
-- Name: guardianships guardianships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guardianships
    ADD CONSTRAINT guardianships_pkey PRIMARY KEY (id);


--
-- Name: health_records health_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.health_records
    ADD CONSTRAINT health_records_pkey PRIMARY KEY (id);


--
-- Name: homework_submissions homework_submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.homework_submissions
    ADD CONSTRAINT homework_submissions_pkey PRIMARY KEY (id);


--
-- Name: homeworks homeworks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.homeworks
    ADD CONSTRAINT homeworks_pkey PRIMARY KEY (id);


--
-- Name: hostel_allocations hostel_allocations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hostel_allocations
    ADD CONSTRAINT hostel_allocations_pkey PRIMARY KEY (id);


--
-- Name: hostel_rooms hostel_rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hostel_rooms
    ADD CONSTRAINT hostel_rooms_pkey PRIMARY KEY (id);


--
-- Name: hostels hostels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hostels
    ADD CONSTRAINT hostels_pkey PRIMARY KEY (id);


--
-- Name: id_card_templates id_card_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.id_card_templates
    ADD CONSTRAINT id_card_templates_pkey PRIMARY KEY (id);


--
-- Name: inventory_items inventory_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_items
    ADD CONSTRAINT inventory_items_pkey PRIMARY KEY (id);


--
-- Name: issued_certificates issued_certificates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.issued_certificates
    ADD CONSTRAINT issued_certificates_pkey PRIMARY KEY (id);


--
-- Name: kb_articles kb_articles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kb_articles
    ADD CONSTRAINT kb_articles_pkey PRIMARY KEY (id);


--
-- Name: ledger_entries ledger_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ledger_entries
    ADD CONSTRAINT ledger_entries_pkey PRIMARY KEY (id);


--
-- Name: lesson_plans lesson_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lesson_plans
    ADD CONSTRAINT lesson_plans_pkey PRIMARY KEY (id);


--
-- Name: live_classes live_classes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.live_classes
    ADD CONSTRAINT live_classes_pkey PRIMARY KEY (id);


--
-- Name: message_logs message_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.message_logs
    ADD CONSTRAINT message_logs_pkey PRIMARY KEY (id);


--
-- Name: message_templates message_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.message_templates
    ADD CONSTRAINT message_templates_pkey PRIMARY KEY (id);


--
-- Name: notices notices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notices
    ADD CONSTRAINT notices_pkey PRIMARY KEY (id);


--
-- Name: online_tests online_tests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.online_tests
    ADD CONSTRAINT online_tests_pkey PRIMARY KEY (id);


--
-- Name: payslips payslips_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payslips
    ADD CONSTRAINT payslips_pkey PRIMARY KEY (id);


--
-- Name: phone_logs phone_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.phone_logs
    ADD CONSTRAINT phone_logs_pkey PRIMARY KEY (id);


--
-- Name: postal_records postal_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.postal_records
    ADD CONSTRAINT postal_records_pkey PRIMARY KEY (id);


--
-- Name: ptm_meetings ptm_meetings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ptm_meetings
    ADD CONSTRAINT ptm_meetings_pkey PRIMARY KEY (id);


--
-- Name: ptm_slots ptm_slots_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ptm_slots
    ADD CONSTRAINT ptm_slots_pkey PRIMARY KEY (id);


--
-- Name: role_assignments role_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_assignments
    ADD CONSTRAINT role_assignments_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: route_stops route_stops_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.route_stops
    ADD CONSTRAINT route_stops_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: schools schools_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schools
    ADD CONSTRAINT schools_pkey PRIMARY KEY (id);


--
-- Name: sections sections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sections
    ADD CONSTRAINT sections_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: staffs staffs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staffs
    ADD CONSTRAINT staffs_pkey PRIMARY KEY (id);


--
-- Name: stock_movements stock_movements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_movements
    ADD CONSTRAINT stock_movements_pkey PRIMARY KEY (id);


--
-- Name: students students_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_pkey PRIMARY KEY (id);


--
-- Name: study_materials study_materials_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.study_materials
    ADD CONSTRAINT study_materials_pkey PRIMARY KEY (id);


--
-- Name: subject_assignments subject_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subject_assignments
    ADD CONSTRAINT subject_assignments_pkey PRIMARY KEY (id);


--
-- Name: subjects subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_pkey PRIMARY KEY (id);


--
-- Name: survey_questions survey_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_questions
    ADD CONSTRAINT survey_questions_pkey PRIMARY KEY (id);


--
-- Name: survey_responses survey_responses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_responses
    ADD CONSTRAINT survey_responses_pkey PRIMARY KEY (id);


--
-- Name: surveys surveys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.surveys
    ADD CONSTRAINT surveys_pkey PRIMARY KEY (id);


--
-- Name: test_attempts test_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_attempts
    ADD CONSTRAINT test_attempts_pkey PRIMARY KEY (id);


--
-- Name: test_questions test_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_questions
    ADD CONSTRAINT test_questions_pkey PRIMARY KEY (id);


--
-- Name: timetable_slots timetable_slots_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.timetable_slots
    ADD CONSTRAINT timetable_slots_pkey PRIMARY KEY (id);


--
-- Name: transport_assignments transport_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transport_assignments
    ADD CONSTRAINT transport_assignments_pkey PRIMARY KEY (id);


--
-- Name: transport_routes transport_routes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transport_routes
    ADD CONSTRAINT transport_routes_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: vehicle_locations vehicle_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicle_locations
    ADD CONSTRAINT vehicle_locations_pkey PRIMARY KEY (id);


--
-- Name: vehicles vehicles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_pkey PRIMARY KEY (id);


--
-- Name: visitors visitors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visitors
    ADD CONSTRAINT visitors_pkey PRIMARY KEY (id);


--
-- Name: web_pages web_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.web_pages
    ADD CONSTRAINT web_pages_pkey PRIMARY KEY (id);


--
-- Name: idx_attendance_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_attendance_unique ON public.attendances USING btree (attendable_type, attendable_id, on_date);


--
-- Name: idx_competency_score_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_competency_score_unique ON public.competency_scores USING btree (competency_id, student_id, term);


--
-- Name: idx_evaluation_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_evaluation_unique ON public.evaluations USING btree (exam_schedule_id, student_id);


--
-- Name: idx_exam_schedule_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_exam_schedule_unique ON public.exam_schedules USING btree (exam_id, section_id, subject_id);


--
-- Name: idx_fee_structure_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_fee_structure_unique ON public.fee_structures USING btree (academic_year_id, grade_id, fee_head_id);


--
-- Name: idx_on_student_id_transport_route_id_c368514e60; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_on_student_id_transport_route_id_c368514e60 ON public.transport_assignments USING btree (student_id, transport_route_id);


--
-- Name: idx_ptm_slot_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ptm_slot_unique ON public.ptm_slots USING btree (ptm_meeting_id, staff_id, starts_at);


--
-- Name: idx_punch_dedupe; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_punch_dedupe ON public.biometric_punches USING btree (biometric_device_id, biometric_id, punched_at);


--
-- Name: idx_result_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_result_unique ON public.exam_results USING btree (exam_schedule_id, student_id);


--
-- Name: idx_slot_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_slot_unique ON public.timetable_slots USING btree (section_id, weekday, starts_at);


--
-- Name: index_academic_years_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_academic_years_on_school_id ON public.academic_years USING btree (school_id);


--
-- Name: index_academic_years_on_school_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_academic_years_on_school_id_and_name ON public.academic_years USING btree (school_id, name);


--
-- Name: index_admission_enquiries_on_assigned_to_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admission_enquiries_on_assigned_to_id ON public.admission_enquiries USING btree (assigned_to_id);


--
-- Name: index_admission_enquiries_on_grade_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admission_enquiries_on_grade_id ON public.admission_enquiries USING btree (grade_id);


--
-- Name: index_admission_enquiries_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admission_enquiries_on_school_id ON public.admission_enquiries USING btree (school_id);


--
-- Name: index_admission_enquiries_on_school_id_and_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admission_enquiries_on_school_id_and_status ON public.admission_enquiries USING btree (school_id, status);


--
-- Name: index_assets_on_assigned_to_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assets_on_assigned_to_id ON public.assets USING btree (assigned_to_id);


--
-- Name: index_assets_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assets_on_school_id ON public.assets USING btree (school_id);


--
-- Name: index_assets_on_school_id_and_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assets_on_school_id_and_code ON public.assets USING btree (school_id, code);


--
-- Name: index_attendances_on_academic_year_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attendances_on_academic_year_id ON public.attendances USING btree (academic_year_id);


--
-- Name: index_attendances_on_attendable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attendances_on_attendable ON public.attendances USING btree (attendable_type, attendable_id);


--
-- Name: index_attendances_on_marked_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attendances_on_marked_by_id ON public.attendances USING btree (marked_by_id);


--
-- Name: index_attendances_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attendances_on_school_id ON public.attendances USING btree (school_id);


--
-- Name: index_attendances_on_school_id_and_on_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attendances_on_school_id_and_on_date ON public.attendances USING btree (school_id, on_date);


--
-- Name: index_attendances_on_section_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attendances_on_section_id ON public.attendances USING btree (section_id);


--
-- Name: index_biometric_devices_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_biometric_devices_on_school_id ON public.biometric_devices USING btree (school_id);


--
-- Name: index_biometric_devices_on_serial_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_biometric_devices_on_serial_number ON public.biometric_devices USING btree (serial_number);


--
-- Name: index_biometric_punches_on_biometric_device_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_biometric_punches_on_biometric_device_id ON public.biometric_punches USING btree (biometric_device_id);


--
-- Name: index_biometric_punches_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_biometric_punches_on_school_id ON public.biometric_punches USING btree (school_id);


--
-- Name: index_book_issues_on_book_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_book_issues_on_book_id ON public.book_issues USING btree (book_id);


--
-- Name: index_book_issues_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_book_issues_on_school_id ON public.book_issues USING btree (school_id);


--
-- Name: index_book_issues_on_school_id_and_returned_on; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_book_issues_on_school_id_and_returned_on ON public.book_issues USING btree (school_id, returned_on);


--
-- Name: index_book_issues_on_staff_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_book_issues_on_staff_id ON public.book_issues USING btree (staff_id);


--
-- Name: index_book_issues_on_student_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_book_issues_on_student_id ON public.book_issues USING btree (student_id);


--
-- Name: index_books_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_books_on_school_id ON public.books USING btree (school_id);


--
-- Name: index_books_on_school_id_and_isbn; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_books_on_school_id_and_isbn ON public.books USING btree (school_id, isbn);


--
-- Name: index_books_on_school_id_and_title; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_books_on_school_id_and_title ON public.books USING btree (school_id, title);


--
-- Name: index_cameras_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cameras_on_school_id ON public.cameras USING btree (school_id);


--
-- Name: index_campus_workers_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_campus_workers_on_school_id ON public.campus_workers USING btree (school_id);


--
-- Name: index_certificate_templates_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_certificate_templates_on_school_id ON public.certificate_templates USING btree (school_id);


--
-- Name: index_chat_messages_on_conversation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_chat_messages_on_conversation_id ON public.chat_messages USING btree (conversation_id);


--
-- Name: index_chat_messages_on_conversation_id_and_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_chat_messages_on_conversation_id_and_created_at ON public.chat_messages USING btree (conversation_id, created_at);


--
-- Name: index_chat_messages_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_chat_messages_on_school_id ON public.chat_messages USING btree (school_id);


--
-- Name: index_chat_messages_on_sender_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_chat_messages_on_sender_id ON public.chat_messages USING btree (sender_id);


--
-- Name: index_competencies_on_grade_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_competencies_on_grade_id ON public.competencies USING btree (grade_id);


--
-- Name: index_competencies_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_competencies_on_school_id ON public.competencies USING btree (school_id);


--
-- Name: index_competencies_on_school_id_and_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_competencies_on_school_id_and_code ON public.competencies USING btree (school_id, code);


--
-- Name: index_competencies_on_subject_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_competencies_on_subject_id ON public.competencies USING btree (subject_id);


--
-- Name: index_competency_scores_on_assessed_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_competency_scores_on_assessed_by_id ON public.competency_scores USING btree (assessed_by_id);


--
-- Name: index_competency_scores_on_competency_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_competency_scores_on_competency_id ON public.competency_scores USING btree (competency_id);


--
-- Name: index_competency_scores_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_competency_scores_on_school_id ON public.competency_scores USING btree (school_id);


--
-- Name: index_competency_scores_on_student_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_competency_scores_on_student_id ON public.competency_scores USING btree (student_id);


--
-- Name: index_conversations_on_guardian_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_conversations_on_guardian_id ON public.conversations USING btree (guardian_id);


--
-- Name: index_conversations_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_conversations_on_school_id ON public.conversations USING btree (school_id);


--
-- Name: index_conversations_on_school_id_and_last_message_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_conversations_on_school_id_and_last_message_at ON public.conversations USING btree (school_id, last_message_at);


--
-- Name: index_conversations_on_staff_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_conversations_on_staff_id ON public.conversations USING btree (staff_id);


--
-- Name: index_conversations_on_student_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_conversations_on_student_id ON public.conversations USING btree (student_id);


--
-- Name: index_departments_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_departments_on_school_id ON public.departments USING btree (school_id);


--
-- Name: index_departments_on_school_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_departments_on_school_id_and_name ON public.departments USING btree (school_id, name);


--
-- Name: index_enrollments_on_academic_year_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_enrollments_on_academic_year_id ON public.enrollments USING btree (academic_year_id);


--
-- Name: index_enrollments_on_academic_year_id_and_student_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_enrollments_on_academic_year_id_and_student_id ON public.enrollments USING btree (academic_year_id, student_id);


--
-- Name: index_enrollments_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_enrollments_on_school_id ON public.enrollments USING btree (school_id);


--
-- Name: index_enrollments_on_section_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_enrollments_on_section_id ON public.enrollments USING btree (section_id);


--
-- Name: index_enrollments_on_student_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_enrollments_on_student_id ON public.enrollments USING btree (student_id);


--
-- Name: index_evaluations_on_evaluator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_evaluations_on_evaluator_id ON public.evaluations USING btree (evaluator_id);


--
-- Name: index_evaluations_on_exam_schedule_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_evaluations_on_exam_schedule_id ON public.evaluations USING btree (exam_schedule_id);


--
-- Name: index_evaluations_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_evaluations_on_school_id ON public.evaluations USING btree (school_id);


--
-- Name: index_evaluations_on_student_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_evaluations_on_student_id ON public.evaluations USING btree (student_id);


--
-- Name: index_exam_results_on_exam_schedule_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_exam_results_on_exam_schedule_id ON public.exam_results USING btree (exam_schedule_id);


--
-- Name: index_exam_results_on_student_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_exam_results_on_student_id ON public.exam_results USING btree (student_id);


--
-- Name: index_exam_schedules_on_exam_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_exam_schedules_on_exam_id ON public.exam_schedules USING btree (exam_id);


--
-- Name: index_exam_schedules_on_section_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_exam_schedules_on_section_id ON public.exam_schedules USING btree (section_id);


--
-- Name: index_exam_schedules_on_subject_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_exam_schedules_on_subject_id ON public.exam_schedules USING btree (subject_id);


--
-- Name: index_exams_on_academic_year_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_exams_on_academic_year_id ON public.exams USING btree (academic_year_id);


--
-- Name: index_exams_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_exams_on_school_id ON public.exams USING btree (school_id);


--
-- Name: index_fee_heads_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fee_heads_on_school_id ON public.fee_heads USING btree (school_id);


--
-- Name: index_fee_heads_on_school_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_fee_heads_on_school_id_and_name ON public.fee_heads USING btree (school_id, name);


--
-- Name: index_fee_invoice_items_on_fee_head_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fee_invoice_items_on_fee_head_id ON public.fee_invoice_items USING btree (fee_head_id);


--
-- Name: index_fee_invoice_items_on_fee_invoice_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fee_invoice_items_on_fee_invoice_id ON public.fee_invoice_items USING btree (fee_invoice_id);


--
-- Name: index_fee_invoices_on_academic_year_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fee_invoices_on_academic_year_id ON public.fee_invoices USING btree (academic_year_id);


--
-- Name: index_fee_invoices_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fee_invoices_on_school_id ON public.fee_invoices USING btree (school_id);


--
-- Name: index_fee_invoices_on_school_id_and_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_fee_invoices_on_school_id_and_number ON public.fee_invoices USING btree (school_id, number);


--
-- Name: index_fee_invoices_on_student_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fee_invoices_on_student_id ON public.fee_invoices USING btree (student_id);


--
-- Name: index_fee_invoices_on_student_id_and_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fee_invoices_on_student_id_and_status ON public.fee_invoices USING btree (student_id, status);


--
-- Name: index_fee_payments_on_fee_invoice_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fee_payments_on_fee_invoice_id ON public.fee_payments USING btree (fee_invoice_id);


--
-- Name: index_fee_payments_on_received_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fee_payments_on_received_by_id ON public.fee_payments USING btree (received_by_id);


--
-- Name: index_fee_payments_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fee_payments_on_school_id ON public.fee_payments USING btree (school_id);


--
-- Name: index_fee_payments_on_school_id_and_paid_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fee_payments_on_school_id_and_paid_at ON public.fee_payments USING btree (school_id, paid_at);


--
-- Name: index_fee_structures_on_academic_year_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fee_structures_on_academic_year_id ON public.fee_structures USING btree (academic_year_id);


--
-- Name: index_fee_structures_on_fee_head_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fee_structures_on_fee_head_id ON public.fee_structures USING btree (fee_head_id);


--
-- Name: index_fee_structures_on_grade_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fee_structures_on_grade_id ON public.fee_structures USING btree (grade_id);


--
-- Name: index_fee_structures_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fee_structures_on_school_id ON public.fee_structures USING btree (school_id);


--
-- Name: index_gate_passes_on_approved_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gate_passes_on_approved_by_id ON public.gate_passes USING btree (approved_by_id);


--
-- Name: index_gate_passes_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gate_passes_on_school_id ON public.gate_passes USING btree (school_id);


--
-- Name: index_gate_passes_on_school_id_and_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gate_passes_on_school_id_and_status ON public.gate_passes USING btree (school_id, status);


--
-- Name: index_gate_passes_on_staff_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gate_passes_on_staff_id ON public.gate_passes USING btree (staff_id);


--
-- Name: index_gate_passes_on_student_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_gate_passes_on_student_id ON public.gate_passes USING btree (student_id);


--
-- Name: index_grades_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_grades_on_school_id ON public.grades USING btree (school_id);


--
-- Name: index_grades_on_school_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_grades_on_school_id_and_name ON public.grades USING btree (school_id, name);


--
-- Name: index_greeting_campaigns_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_greeting_campaigns_on_school_id ON public.greeting_campaigns USING btree (school_id);


--
-- Name: index_guardians_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_guardians_on_school_id ON public.guardians USING btree (school_id);


--
-- Name: index_guardians_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_guardians_on_user_id ON public.guardians USING btree (user_id);


--
-- Name: index_guardianships_on_guardian_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_guardianships_on_guardian_id ON public.guardianships USING btree (guardian_id);


--
-- Name: index_guardianships_on_guardian_id_and_student_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_guardianships_on_guardian_id_and_student_id ON public.guardianships USING btree (guardian_id, student_id);


--
-- Name: index_guardianships_on_student_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_guardianships_on_student_id ON public.guardianships USING btree (student_id);


--
-- Name: index_health_records_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_health_records_on_school_id ON public.health_records USING btree (school_id);


--
-- Name: index_health_records_on_student_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_health_records_on_student_id ON public.health_records USING btree (student_id);


--
-- Name: index_health_records_on_student_id_and_checked_on; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_health_records_on_student_id_and_checked_on ON public.health_records USING btree (student_id, checked_on);


--
-- Name: index_homework_submissions_on_homework_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_homework_submissions_on_homework_id ON public.homework_submissions USING btree (homework_id);


--
-- Name: index_homework_submissions_on_homework_id_and_student_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_homework_submissions_on_homework_id_and_student_id ON public.homework_submissions USING btree (homework_id, student_id);


--
-- Name: index_homework_submissions_on_student_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_homework_submissions_on_student_id ON public.homework_submissions USING btree (student_id);


--
-- Name: index_homeworks_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_homeworks_on_school_id ON public.homeworks USING btree (school_id);


--
-- Name: index_homeworks_on_section_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_homeworks_on_section_id ON public.homeworks USING btree (section_id);


--
-- Name: index_homeworks_on_section_id_and_due_on; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_homeworks_on_section_id_and_due_on ON public.homeworks USING btree (section_id, due_on);


--
-- Name: index_homeworks_on_staff_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_homeworks_on_staff_id ON public.homeworks USING btree (staff_id);


--
-- Name: index_homeworks_on_subject_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_homeworks_on_subject_id ON public.homeworks USING btree (subject_id);


--
-- Name: index_hostel_allocations_on_hostel_room_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_hostel_allocations_on_hostel_room_id ON public.hostel_allocations USING btree (hostel_room_id);


--
-- Name: index_hostel_allocations_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_hostel_allocations_on_school_id ON public.hostel_allocations USING btree (school_id);


--
-- Name: index_hostel_allocations_on_student_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_hostel_allocations_on_student_id ON public.hostel_allocations USING btree (student_id);


--
-- Name: index_hostel_allocations_on_student_id_and_from_on; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_hostel_allocations_on_student_id_and_from_on ON public.hostel_allocations USING btree (student_id, from_on);


--
-- Name: index_hostel_rooms_on_hostel_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_hostel_rooms_on_hostel_id ON public.hostel_rooms USING btree (hostel_id);


--
-- Name: index_hostel_rooms_on_hostel_id_and_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_hostel_rooms_on_hostel_id_and_number ON public.hostel_rooms USING btree (hostel_id, number);


--
-- Name: index_hostel_rooms_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_hostel_rooms_on_school_id ON public.hostel_rooms USING btree (school_id);


--
-- Name: index_hostels_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_hostels_on_school_id ON public.hostels USING btree (school_id);


--
-- Name: index_hostels_on_warden_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_hostels_on_warden_id ON public.hostels USING btree (warden_id);


--
-- Name: index_id_card_templates_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_id_card_templates_on_school_id ON public.id_card_templates USING btree (school_id);


--
-- Name: index_inventory_items_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_inventory_items_on_school_id ON public.inventory_items USING btree (school_id);


--
-- Name: index_inventory_items_on_school_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_inventory_items_on_school_id_and_name ON public.inventory_items USING btree (school_id, name);


--
-- Name: index_issued_certificates_on_certificate_template_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_issued_certificates_on_certificate_template_id ON public.issued_certificates USING btree (certificate_template_id);


--
-- Name: index_issued_certificates_on_issued_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_issued_certificates_on_issued_by_id ON public.issued_certificates USING btree (issued_by_id);


--
-- Name: index_issued_certificates_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_issued_certificates_on_school_id ON public.issued_certificates USING btree (school_id);


--
-- Name: index_issued_certificates_on_school_id_and_number; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_issued_certificates_on_school_id_and_number ON public.issued_certificates USING btree (school_id, number);


--
-- Name: index_issued_certificates_on_student_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_issued_certificates_on_student_id ON public.issued_certificates USING btree (student_id);


--
-- Name: index_kb_articles_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_kb_articles_on_school_id ON public.kb_articles USING btree (school_id);


--
-- Name: index_kb_articles_on_school_id_and_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_kb_articles_on_school_id_and_category ON public.kb_articles USING btree (school_id, category);


--
-- Name: index_ledger_entries_on_recorded_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ledger_entries_on_recorded_by_id ON public.ledger_entries USING btree (recorded_by_id);


--
-- Name: index_ledger_entries_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ledger_entries_on_school_id ON public.ledger_entries USING btree (school_id);


--
-- Name: index_ledger_entries_on_school_id_and_on_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ledger_entries_on_school_id_and_on_date ON public.ledger_entries USING btree (school_id, on_date);


--
-- Name: index_lesson_plans_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lesson_plans_on_school_id ON public.lesson_plans USING btree (school_id);


--
-- Name: index_lesson_plans_on_school_id_and_week_of; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lesson_plans_on_school_id_and_week_of ON public.lesson_plans USING btree (school_id, week_of);


--
-- Name: index_lesson_plans_on_section_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lesson_plans_on_section_id ON public.lesson_plans USING btree (section_id);


--
-- Name: index_lesson_plans_on_staff_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lesson_plans_on_staff_id ON public.lesson_plans USING btree (staff_id);


--
-- Name: index_lesson_plans_on_subject_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lesson_plans_on_subject_id ON public.lesson_plans USING btree (subject_id);


--
-- Name: index_live_classes_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_live_classes_on_school_id ON public.live_classes USING btree (school_id);


--
-- Name: index_live_classes_on_school_id_and_starts_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_live_classes_on_school_id_and_starts_at ON public.live_classes USING btree (school_id, starts_at);


--
-- Name: index_live_classes_on_section_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_live_classes_on_section_id ON public.live_classes USING btree (section_id);


--
-- Name: index_live_classes_on_staff_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_live_classes_on_staff_id ON public.live_classes USING btree (staff_id);


--
-- Name: index_live_classes_on_subject_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_live_classes_on_subject_id ON public.live_classes USING btree (subject_id);


--
-- Name: index_message_logs_on_message_template_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_message_logs_on_message_template_id ON public.message_logs USING btree (message_template_id);


--
-- Name: index_message_logs_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_message_logs_on_school_id ON public.message_logs USING btree (school_id);


--
-- Name: index_message_logs_on_school_id_and_sent_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_message_logs_on_school_id_and_sent_at ON public.message_logs USING btree (school_id, sent_at);


--
-- Name: index_message_logs_on_sent_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_message_logs_on_sent_by_id ON public.message_logs USING btree (sent_by_id);


--
-- Name: index_message_templates_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_message_templates_on_school_id ON public.message_templates USING btree (school_id);


--
-- Name: index_notices_on_created_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notices_on_created_by_id ON public.notices USING btree (created_by_id);


--
-- Name: index_notices_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notices_on_school_id ON public.notices USING btree (school_id);


--
-- Name: index_notices_on_school_id_and_published_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notices_on_school_id_and_published_at ON public.notices USING btree (school_id, published_at);


--
-- Name: index_notices_on_section_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notices_on_section_id ON public.notices USING btree (section_id);


--
-- Name: index_online_tests_on_academic_year_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_online_tests_on_academic_year_id ON public.online_tests USING btree (academic_year_id);


--
-- Name: index_online_tests_on_grade_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_online_tests_on_grade_id ON public.online_tests USING btree (grade_id);


--
-- Name: index_online_tests_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_online_tests_on_school_id ON public.online_tests USING btree (school_id);


--
-- Name: index_online_tests_on_school_id_and_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_online_tests_on_school_id_and_status ON public.online_tests USING btree (school_id, status);


--
-- Name: index_online_tests_on_staff_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_online_tests_on_staff_id ON public.online_tests USING btree (staff_id);


--
-- Name: index_online_tests_on_subject_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_online_tests_on_subject_id ON public.online_tests USING btree (subject_id);


--
-- Name: index_payslips_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payslips_on_school_id ON public.payslips USING btree (school_id);


--
-- Name: index_payslips_on_staff_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payslips_on_staff_id ON public.payslips USING btree (staff_id);


--
-- Name: index_payslips_on_staff_id_and_period; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_payslips_on_staff_id_and_period ON public.payslips USING btree (staff_id, period);


--
-- Name: index_phone_logs_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_phone_logs_on_school_id ON public.phone_logs USING btree (school_id);


--
-- Name: index_postal_records_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_postal_records_on_school_id ON public.postal_records USING btree (school_id);


--
-- Name: index_ptm_meetings_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ptm_meetings_on_school_id ON public.ptm_meetings USING btree (school_id);


--
-- Name: index_ptm_meetings_on_school_id_and_on_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ptm_meetings_on_school_id_and_on_date ON public.ptm_meetings USING btree (school_id, on_date);


--
-- Name: index_ptm_meetings_on_section_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ptm_meetings_on_section_id ON public.ptm_meetings USING btree (section_id);


--
-- Name: index_ptm_slots_on_ptm_meeting_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ptm_slots_on_ptm_meeting_id ON public.ptm_slots USING btree (ptm_meeting_id);


--
-- Name: index_ptm_slots_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ptm_slots_on_school_id ON public.ptm_slots USING btree (school_id);


--
-- Name: index_ptm_slots_on_staff_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ptm_slots_on_staff_id ON public.ptm_slots USING btree (staff_id);


--
-- Name: index_ptm_slots_on_student_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ptm_slots_on_student_id ON public.ptm_slots USING btree (student_id);


--
-- Name: index_role_assignments_on_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_role_assignments_on_role_id ON public.role_assignments USING btree (role_id);


--
-- Name: index_role_assignments_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_role_assignments_on_user_id ON public.role_assignments USING btree (user_id);


--
-- Name: index_role_assignments_on_user_id_and_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_role_assignments_on_user_id_and_role_id ON public.role_assignments USING btree (user_id, role_id);


--
-- Name: index_roles_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_roles_on_school_id ON public.roles USING btree (school_id);


--
-- Name: index_roles_on_school_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_roles_on_school_id_and_name ON public.roles USING btree (school_id, name);


--
-- Name: index_route_stops_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_route_stops_on_school_id ON public.route_stops USING btree (school_id);


--
-- Name: index_route_stops_on_transport_route_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_route_stops_on_transport_route_id ON public.route_stops USING btree (transport_route_id);


--
-- Name: index_schools_on_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_schools_on_code ON public.schools USING btree (code);


--
-- Name: index_schools_on_subdomain; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_schools_on_subdomain ON public.schools USING btree (subdomain);


--
-- Name: index_sections_on_class_teacher_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sections_on_class_teacher_id ON public.sections USING btree (class_teacher_id);


--
-- Name: index_sections_on_grade_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sections_on_grade_id ON public.sections USING btree (grade_id);


--
-- Name: index_sections_on_grade_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_sections_on_grade_id_and_name ON public.sections USING btree (grade_id, name);


--
-- Name: index_sections_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sections_on_school_id ON public.sections USING btree (school_id);


--
-- Name: index_sessions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sessions_on_user_id ON public.sessions USING btree (user_id);


--
-- Name: index_staffs_on_department_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_staffs_on_department_id ON public.staffs USING btree (department_id);


--
-- Name: index_staffs_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_staffs_on_school_id ON public.staffs USING btree (school_id);


--
-- Name: index_staffs_on_school_id_and_biometric_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_staffs_on_school_id_and_biometric_id ON public.staffs USING btree (school_id, biometric_id);


--
-- Name: index_staffs_on_school_id_and_employee_no; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_staffs_on_school_id_and_employee_no ON public.staffs USING btree (school_id, employee_no);


--
-- Name: index_staffs_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_staffs_on_user_id ON public.staffs USING btree (user_id);


--
-- Name: index_stock_movements_on_inventory_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stock_movements_on_inventory_item_id ON public.stock_movements USING btree (inventory_item_id);


--
-- Name: index_stock_movements_on_recorded_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stock_movements_on_recorded_by_id ON public.stock_movements USING btree (recorded_by_id);


--
-- Name: index_stock_movements_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stock_movements_on_school_id ON public.stock_movements USING btree (school_id);


--
-- Name: index_students_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_students_on_school_id ON public.students USING btree (school_id);


--
-- Name: index_students_on_school_id_and_admission_no; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_students_on_school_id_and_admission_no ON public.students USING btree (school_id, admission_no);


--
-- Name: index_students_on_school_id_and_biometric_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_students_on_school_id_and_biometric_id ON public.students USING btree (school_id, biometric_id);


--
-- Name: index_students_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_students_on_user_id ON public.students USING btree (user_id);


--
-- Name: index_study_materials_on_grade_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_study_materials_on_grade_id ON public.study_materials USING btree (grade_id);


--
-- Name: index_study_materials_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_study_materials_on_school_id ON public.study_materials USING btree (school_id);


--
-- Name: index_study_materials_on_school_id_and_kind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_study_materials_on_school_id_and_kind ON public.study_materials USING btree (school_id, kind);


--
-- Name: index_study_materials_on_staff_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_study_materials_on_staff_id ON public.study_materials USING btree (staff_id);


--
-- Name: index_study_materials_on_subject_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_study_materials_on_subject_id ON public.study_materials USING btree (subject_id);


--
-- Name: index_subject_assignments_on_section_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subject_assignments_on_section_id ON public.subject_assignments USING btree (section_id);


--
-- Name: index_subject_assignments_on_section_id_and_subject_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_subject_assignments_on_section_id_and_subject_id ON public.subject_assignments USING btree (section_id, subject_id);


--
-- Name: index_subject_assignments_on_staff_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subject_assignments_on_staff_id ON public.subject_assignments USING btree (staff_id);


--
-- Name: index_subject_assignments_on_subject_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subject_assignments_on_subject_id ON public.subject_assignments USING btree (subject_id);


--
-- Name: index_subjects_on_grade_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subjects_on_grade_id ON public.subjects USING btree (grade_id);


--
-- Name: index_subjects_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subjects_on_school_id ON public.subjects USING btree (school_id);


--
-- Name: index_subjects_on_school_id_and_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_subjects_on_school_id_and_code ON public.subjects USING btree (school_id, code);


--
-- Name: index_survey_questions_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_survey_questions_on_school_id ON public.survey_questions USING btree (school_id);


--
-- Name: index_survey_questions_on_survey_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_survey_questions_on_survey_id ON public.survey_questions USING btree (survey_id);


--
-- Name: index_survey_responses_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_survey_responses_on_school_id ON public.survey_responses USING btree (school_id);


--
-- Name: index_survey_responses_on_survey_question_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_survey_responses_on_survey_question_id ON public.survey_responses USING btree (survey_question_id);


--
-- Name: index_survey_responses_on_survey_question_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_survey_responses_on_survey_question_id_and_user_id ON public.survey_responses USING btree (survey_question_id, user_id);


--
-- Name: index_survey_responses_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_survey_responses_on_user_id ON public.survey_responses USING btree (user_id);


--
-- Name: index_surveys_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_surveys_on_school_id ON public.surveys USING btree (school_id);


--
-- Name: index_test_attempts_on_online_test_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_test_attempts_on_online_test_id ON public.test_attempts USING btree (online_test_id);


--
-- Name: index_test_attempts_on_online_test_id_and_student_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_test_attempts_on_online_test_id_and_student_id ON public.test_attempts USING btree (online_test_id, student_id);


--
-- Name: index_test_attempts_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_test_attempts_on_school_id ON public.test_attempts USING btree (school_id);


--
-- Name: index_test_attempts_on_student_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_test_attempts_on_student_id ON public.test_attempts USING btree (student_id);


--
-- Name: index_test_questions_on_online_test_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_test_questions_on_online_test_id ON public.test_questions USING btree (online_test_id);


--
-- Name: index_test_questions_on_online_test_id_and_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_test_questions_on_online_test_id_and_position ON public.test_questions USING btree (online_test_id, "position");


--
-- Name: index_test_questions_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_test_questions_on_school_id ON public.test_questions USING btree (school_id);


--
-- Name: index_timetable_slots_on_academic_year_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_timetable_slots_on_academic_year_id ON public.timetable_slots USING btree (academic_year_id);


--
-- Name: index_timetable_slots_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_timetable_slots_on_school_id ON public.timetable_slots USING btree (school_id);


--
-- Name: index_timetable_slots_on_section_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_timetable_slots_on_section_id ON public.timetable_slots USING btree (section_id);


--
-- Name: index_timetable_slots_on_staff_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_timetable_slots_on_staff_id ON public.timetable_slots USING btree (staff_id);


--
-- Name: index_timetable_slots_on_subject_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_timetable_slots_on_subject_id ON public.timetable_slots USING btree (subject_id);


--
-- Name: index_transport_assignments_on_route_stop_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_transport_assignments_on_route_stop_id ON public.transport_assignments USING btree (route_stop_id);


--
-- Name: index_transport_assignments_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_transport_assignments_on_school_id ON public.transport_assignments USING btree (school_id);


--
-- Name: index_transport_assignments_on_student_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_transport_assignments_on_student_id ON public.transport_assignments USING btree (student_id);


--
-- Name: index_transport_assignments_on_transport_route_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_transport_assignments_on_transport_route_id ON public.transport_assignments USING btree (transport_route_id);


--
-- Name: index_transport_routes_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_transport_routes_on_school_id ON public.transport_routes USING btree (school_id);


--
-- Name: index_transport_routes_on_vehicle_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_transport_routes_on_vehicle_id ON public.transport_routes USING btree (vehicle_id);


--
-- Name: index_users_on_email_address; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email_address ON public.users USING btree (email_address);


--
-- Name: index_users_on_phone; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_phone ON public.users USING btree (phone) WHERE (phone IS NOT NULL);


--
-- Name: index_users_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_school_id ON public.users USING btree (school_id);


--
-- Name: index_vehicle_locations_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vehicle_locations_on_school_id ON public.vehicle_locations USING btree (school_id);


--
-- Name: index_vehicle_locations_on_vehicle_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vehicle_locations_on_vehicle_id ON public.vehicle_locations USING btree (vehicle_id);


--
-- Name: index_vehicle_locations_on_vehicle_id_and_recorded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vehicle_locations_on_vehicle_id_and_recorded_at ON public.vehicle_locations USING btree (vehicle_id, recorded_at);


--
-- Name: index_vehicles_on_driver_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vehicles_on_driver_id ON public.vehicles USING btree (driver_id);


--
-- Name: index_vehicles_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vehicles_on_school_id ON public.vehicles USING btree (school_id);


--
-- Name: index_vehicles_on_school_id_and_registration_no; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_vehicles_on_school_id_and_registration_no ON public.vehicles USING btree (school_id, registration_no);


--
-- Name: index_visitors_on_meeting_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_visitors_on_meeting_id ON public.visitors USING btree (meeting_id);


--
-- Name: index_visitors_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_visitors_on_school_id ON public.visitors USING btree (school_id);


--
-- Name: index_visitors_on_school_id_and_in_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_visitors_on_school_id_and_in_at ON public.visitors USING btree (school_id, in_at);


--
-- Name: index_web_pages_on_school_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_web_pages_on_school_id ON public.web_pages USING btree (school_id);


--
-- Name: index_web_pages_on_school_id_and_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_web_pages_on_school_id_and_slug ON public.web_pages USING btree (school_id, slug);


--
-- Name: lesson_plans fk_rails_012692f4cb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lesson_plans
    ADD CONSTRAINT fk_rails_012692f4cb FOREIGN KEY (section_id) REFERENCES public.sections(id);


--
-- Name: timetable_slots fk_rails_03bbd967c8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.timetable_slots
    ADD CONSTRAINT fk_rails_03bbd967c8 FOREIGN KEY (staff_id) REFERENCES public.staffs(id);


--
-- Name: message_logs fk_rails_049c65a729; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.message_logs
    ADD CONSTRAINT fk_rails_049c65a729 FOREIGN KEY (sent_by_id) REFERENCES public.users(id);


--
-- Name: timetable_slots fk_rails_055acf3db1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.timetable_slots
    ADD CONSTRAINT fk_rails_055acf3db1 FOREIGN KEY (academic_year_id) REFERENCES public.academic_years(id);


--
-- Name: evaluations fk_rails_0569adefcd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.evaluations
    ADD CONSTRAINT fk_rails_0569adefcd FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: stock_movements fk_rails_05ce662104; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_movements
    ADD CONSTRAINT fk_rails_05ce662104 FOREIGN KEY (inventory_item_id) REFERENCES public.inventory_items(id);


--
-- Name: fee_structures fk_rails_07c88719b9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fee_structures
    ADD CONSTRAINT fk_rails_07c88719b9 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: transport_assignments fk_rails_09d8fa4418; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transport_assignments
    ADD CONSTRAINT fk_rails_09d8fa4418 FOREIGN KEY (transport_route_id) REFERENCES public.transport_routes(id);


--
-- Name: students fk_rails_0adebddbd5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT fk_rails_0adebddbd5 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: exams fk_rails_0baf410228; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exams
    ADD CONSTRAINT fk_rails_0baf410228 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: fee_invoice_items fk_rails_0d94eef0aa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fee_invoice_items
    ADD CONSTRAINT fk_rails_0d94eef0aa FOREIGN KEY (fee_head_id) REFERENCES public.fee_heads(id);


--
-- Name: evaluations fk_rails_112c4a47ec; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.evaluations
    ADD CONSTRAINT fk_rails_112c4a47ec FOREIGN KEY (student_id) REFERENCES public.students(id);


--
-- Name: lesson_plans fk_rails_1166793e0a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lesson_plans
    ADD CONSTRAINT fk_rails_1166793e0a FOREIGN KEY (subject_id) REFERENCES public.subjects(id);


--
-- Name: fee_structures fk_rails_12a3fc0c37; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fee_structures
    ADD CONSTRAINT fk_rails_12a3fc0c37 FOREIGN KEY (fee_head_id) REFERENCES public.fee_heads(id);


--
-- Name: students fk_rails_148c9e88f4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT fk_rails_148c9e88f4 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: exam_schedules fk_rails_164caf8cd2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exam_schedules
    ADD CONSTRAINT fk_rails_164caf8cd2 FOREIGN KEY (exam_id) REFERENCES public.exams(id);


--
-- Name: ptm_meetings fk_rails_177a642180; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ptm_meetings
    ADD CONSTRAINT fk_rails_177a642180 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: competency_scores fk_rails_17e8790c95; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competency_scores
    ADD CONSTRAINT fk_rails_17e8790c95 FOREIGN KEY (assessed_by_id) REFERENCES public.staffs(id);


--
-- Name: study_materials fk_rails_1867868c7c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.study_materials
    ADD CONSTRAINT fk_rails_1867868c7c FOREIGN KEY (grade_id) REFERENCES public.grades(id);


--
-- Name: homework_submissions fk_rails_1954c411ec; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.homework_submissions
    ADD CONSTRAINT fk_rails_1954c411ec FOREIGN KEY (homework_id) REFERENCES public.homeworks(id);


--
-- Name: online_tests fk_rails_19b78aae51; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.online_tests
    ADD CONSTRAINT fk_rails_19b78aae51 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: hostel_rooms fk_rails_1a4d5f7892; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hostel_rooms
    ADD CONSTRAINT fk_rails_1a4d5f7892 FOREIGN KEY (hostel_id) REFERENCES public.hostels(id);


--
-- Name: test_attempts fk_rails_1ae7c4a1f3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_attempts
    ADD CONSTRAINT fk_rails_1ae7c4a1f3 FOREIGN KEY (student_id) REFERENCES public.students(id);


--
-- Name: ledger_entries fk_rails_1d53b50b68; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ledger_entries
    ADD CONSTRAINT fk_rails_1d53b50b68 FOREIGN KEY (recorded_by_id) REFERENCES public.users(id);


--
-- Name: evaluations fk_rails_1dee3a6b85; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.evaluations
    ADD CONSTRAINT fk_rails_1dee3a6b85 FOREIGN KEY (exam_schedule_id) REFERENCES public.exam_schedules(id);


--
-- Name: issued_certificates fk_rails_1fc940026d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.issued_certificates
    ADD CONSTRAINT fk_rails_1fc940026d FOREIGN KEY (issued_by_id) REFERENCES public.users(id);


--
-- Name: survey_responses fk_rails_2368f705b4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_responses
    ADD CONSTRAINT fk_rails_2368f705b4 FOREIGN KEY (survey_question_id) REFERENCES public.survey_questions(id);


--
-- Name: guardians fk_rails_27b6883457; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guardians
    ADD CONSTRAINT fk_rails_27b6883457 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: study_materials fk_rails_280709668c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.study_materials
    ADD CONSTRAINT fk_rails_280709668c FOREIGN KEY (subject_id) REFERENCES public.subjects(id);


--
-- Name: issued_certificates fk_rails_2811a27a1f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.issued_certificates
    ADD CONSTRAINT fk_rails_2811a27a1f FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: live_classes fk_rails_28e661aec8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.live_classes
    ADD CONSTRAINT fk_rails_28e661aec8 FOREIGN KEY (section_id) REFERENCES public.sections(id);


--
-- Name: fee_invoices fk_rails_2947516f49; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fee_invoices
    ADD CONSTRAINT fk_rails_2947516f49 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: notices fk_rails_2c1a9f3de6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notices
    ADD CONSTRAINT fk_rails_2c1a9f3de6 FOREIGN KEY (created_by_id) REFERENCES public.users(id);


--
-- Name: attendances fk_rails_2d8c655a59; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendances
    ADD CONSTRAINT fk_rails_2d8c655a59 FOREIGN KEY (academic_year_id) REFERENCES public.academic_years(id);


--
-- Name: test_questions fk_rails_2e79f3541d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_questions
    ADD CONSTRAINT fk_rails_2e79f3541d FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: subject_assignments fk_rails_30251fea97; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subject_assignments
    ADD CONSTRAINT fk_rails_30251fea97 FOREIGN KEY (section_id) REFERENCES public.sections(id);


--
-- Name: exam_results fk_rails_30b8dff9fa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exam_results
    ADD CONSTRAINT fk_rails_30b8dff9fa FOREIGN KEY (student_id) REFERENCES public.students(id);


--
-- Name: admission_enquiries fk_rails_3347ee4f67; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admission_enquiries
    ADD CONSTRAINT fk_rails_3347ee4f67 FOREIGN KEY (grade_id) REFERENCES public.grades(id);


--
-- Name: fee_payments fk_rails_338ade3c14; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fee_payments
    ADD CONSTRAINT fk_rails_338ade3c14 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: subjects fk_rails_33d539df11; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT fk_rails_33d539df11 FOREIGN KEY (grade_id) REFERENCES public.grades(id);


--
-- Name: ptm_slots fk_rails_34607f45cb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ptm_slots
    ADD CONSTRAINT fk_rails_34607f45cb FOREIGN KEY (staff_id) REFERENCES public.staffs(id);


--
-- Name: assets fk_rails_3862b8168a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assets
    ADD CONSTRAINT fk_rails_3862b8168a FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: issued_certificates fk_rails_392859516d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.issued_certificates
    ADD CONSTRAINT fk_rails_392859516d FOREIGN KEY (certificate_template_id) REFERENCES public.certificate_templates(id);


--
-- Name: health_records fk_rails_39bc391457; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.health_records
    ADD CONSTRAINT fk_rails_39bc391457 FOREIGN KEY (student_id) REFERENCES public.students(id);


--
-- Name: fee_heads fk_rails_3b5c836ba8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fee_heads
    ADD CONSTRAINT fk_rails_3b5c836ba8 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: postal_records fk_rails_3c2cc49b85; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.postal_records
    ADD CONSTRAINT fk_rails_3c2cc49b85 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: visitors fk_rails_3e362c2885; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visitors
    ADD CONSTRAINT fk_rails_3e362c2885 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: ptm_slots fk_rails_3ffc744f23; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ptm_slots
    ADD CONSTRAINT fk_rails_3ffc744f23 FOREIGN KEY (student_id) REFERENCES public.students(id);


--
-- Name: subject_assignments fk_rails_40ce893fc7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subject_assignments
    ADD CONSTRAINT fk_rails_40ce893fc7 FOREIGN KEY (subject_id) REFERENCES public.subjects(id);


--
-- Name: exam_schedules fk_rails_4320912b40; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exam_schedules
    ADD CONSTRAINT fk_rails_4320912b40 FOREIGN KEY (section_id) REFERENCES public.sections(id);


--
-- Name: message_logs fk_rails_438d6ab342; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.message_logs
    ADD CONSTRAINT fk_rails_438d6ab342 FOREIGN KEY (message_template_id) REFERENCES public.message_templates(id);


--
-- Name: books fk_rails_44081d55ae; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.books
    ADD CONSTRAINT fk_rails_44081d55ae FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: timetable_slots fk_rails_495a8a19ba; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.timetable_slots
    ADD CONSTRAINT fk_rails_495a8a19ba FOREIGN KEY (section_id) REFERENCES public.sections(id);


--
-- Name: fee_payments fk_rails_4a111ceedb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fee_payments
    ADD CONSTRAINT fk_rails_4a111ceedb FOREIGN KEY (received_by_id) REFERENCES public.users(id);


--
-- Name: campus_workers fk_rails_4a6ae2b7f2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campus_workers
    ADD CONSTRAINT fk_rails_4a6ae2b7f2 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: fee_invoices fk_rails_4bde795cd5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fee_invoices
    ADD CONSTRAINT fk_rails_4bde795cd5 FOREIGN KEY (student_id) REFERENCES public.students(id);


--
-- Name: competency_scores fk_rails_4c4e11e6f0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competency_scores
    ADD CONSTRAINT fk_rails_4c4e11e6f0 FOREIGN KEY (student_id) REFERENCES public.students(id);


--
-- Name: hostel_allocations fk_rails_4cb5d1eef5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hostel_allocations
    ADD CONSTRAINT fk_rails_4cb5d1eef5 FOREIGN KEY (hostel_room_id) REFERENCES public.hostel_rooms(id);


--
-- Name: departments fk_rails_4ce931b154; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT fk_rails_4ce931b154 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: id_card_templates fk_rails_4d6cb21731; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.id_card_templates
    ADD CONSTRAINT fk_rails_4d6cb21731 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: surveys fk_rails_4e4d727e4b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.surveys
    ADD CONSTRAINT fk_rails_4e4d727e4b FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: cameras fk_rails_50b1469579; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cameras
    ADD CONSTRAINT fk_rails_50b1469579 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: ledger_entries fk_rails_542d5ae6d9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ledger_entries
    ADD CONSTRAINT fk_rails_542d5ae6d9 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: conversations fk_rails_5483ccdb4e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT fk_rails_5483ccdb4e FOREIGN KEY (student_id) REFERENCES public.students(id);


--
-- Name: inventory_items fk_rails_59907c2d31; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_items
    ADD CONSTRAINT fk_rails_59907c2d31 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: transport_assignments fk_rails_5be7ecebcd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transport_assignments
    ADD CONSTRAINT fk_rails_5be7ecebcd FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: health_records fk_rails_5c92094ce5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.health_records
    ADD CONSTRAINT fk_rails_5c92094ce5 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: enrollments fk_rails_5cf88b78f2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT fk_rails_5cf88b78f2 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: guardianships fk_rails_5e71953f0b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guardianships
    ADD CONSTRAINT fk_rails_5e71953f0b FOREIGN KEY (guardian_id) REFERENCES public.guardians(id);


--
-- Name: sections fk_rails_61d9612b47; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sections
    ADD CONSTRAINT fk_rails_61d9612b47 FOREIGN KEY (grade_id) REFERENCES public.grades(id);


--
-- Name: chat_messages fk_rails_6223514182; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT fk_rails_6223514182 FOREIGN KEY (sender_id) REFERENCES public.users(id);


--
-- Name: guardianships fk_rails_627583fa81; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guardianships
    ADD CONSTRAINT fk_rails_627583fa81 FOREIGN KEY (student_id) REFERENCES public.students(id);


--
-- Name: conversations fk_rails_6544715e63; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT fk_rails_6544715e63 FOREIGN KEY (guardian_id) REFERENCES public.guardians(id);


--
-- Name: test_attempts fk_rails_656242f161; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_attempts
    ADD CONSTRAINT fk_rails_656242f161 FOREIGN KEY (online_test_id) REFERENCES public.online_tests(id);


--
-- Name: admission_enquiries fk_rails_6573417436; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admission_enquiries
    ADD CONSTRAINT fk_rails_6573417436 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: attendances fk_rails_675daf6ad7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendances
    ADD CONSTRAINT fk_rails_675daf6ad7 FOREIGN KEY (section_id) REFERENCES public.sections(id);


--
-- Name: book_issues fk_rails_691d39ba73; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.book_issues
    ADD CONSTRAINT fk_rails_691d39ba73 FOREIGN KEY (staff_id) REFERENCES public.staffs(id);


--
-- Name: competencies fk_rails_6979bb553e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competencies
    ADD CONSTRAINT fk_rails_6979bb553e FOREIGN KEY (grade_id) REFERENCES public.grades(id);


--
-- Name: online_tests fk_rails_6a8066ca8d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.online_tests
    ADD CONSTRAINT fk_rails_6a8066ca8d FOREIGN KEY (subject_id) REFERENCES public.subjects(id);


--
-- Name: phone_logs fk_rails_6a9a6ee9c3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.phone_logs
    ADD CONSTRAINT fk_rails_6a9a6ee9c3 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: route_stops fk_rails_6b8a6fb9f5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.route_stops
    ADD CONSTRAINT fk_rails_6b8a6fb9f5 FOREIGN KEY (transport_route_id) REFERENCES public.transport_routes(id);


--
-- Name: online_tests fk_rails_6bb054fb91; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.online_tests
    ADD CONSTRAINT fk_rails_6bb054fb91 FOREIGN KEY (academic_year_id) REFERENCES public.academic_years(id);


--
-- Name: assets fk_rails_6dbcd31306; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assets
    ADD CONSTRAINT fk_rails_6dbcd31306 FOREIGN KEY (assigned_to_id) REFERENCES public.staffs(id);


--
-- Name: vehicles fk_rails_6dc414cb09; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT fk_rails_6dc414cb09 FOREIGN KEY (driver_id) REFERENCES public.staffs(id);


--
-- Name: enrollments fk_rails_6e4789b133; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT fk_rails_6e4789b133 FOREIGN KEY (section_id) REFERENCES public.sections(id);


--
-- Name: chat_messages fk_rails_6ede0d6992; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT fk_rails_6ede0d6992 FOREIGN KEY (conversation_id) REFERENCES public.conversations(id);


--
-- Name: academic_years fk_rails_6f46cfb03a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.academic_years
    ADD CONSTRAINT fk_rails_6f46cfb03a FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: fee_structures fk_rails_72da422253; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fee_structures
    ADD CONSTRAINT fk_rails_72da422253 FOREIGN KEY (academic_year_id) REFERENCES public.academic_years(id);


--
-- Name: sessions fk_rails_758836b4f0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT fk_rails_758836b4f0 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: roles fk_rails_75955eee5f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT fk_rails_75955eee5f FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: staffs fk_rails_767698896e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staffs
    ADD CONSTRAINT fk_rails_767698896e FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: vehicle_locations fk_rails_7680ae38eb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicle_locations
    ADD CONSTRAINT fk_rails_7680ae38eb FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: vehicles fk_rails_76ba85b99d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT fk_rails_76ba85b99d FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: hostel_rooms fk_rails_77422bd87a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hostel_rooms
    ADD CONSTRAINT fk_rails_77422bd87a FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: live_classes fk_rails_783a8d0d5f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.live_classes
    ADD CONSTRAINT fk_rails_783a8d0d5f FOREIGN KEY (staff_id) REFERENCES public.staffs(id);


--
-- Name: homeworks fk_rails_7858a4052d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.homeworks
    ADD CONSTRAINT fk_rails_7858a4052d FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: lesson_plans fk_rails_79e0d78a8c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lesson_plans
    ADD CONSTRAINT fk_rails_79e0d78a8c FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: survey_responses fk_rails_7a71a34959; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_responses
    ADD CONSTRAINT fk_rails_7a71a34959 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: live_classes fk_rails_7b28767f52; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.live_classes
    ADD CONSTRAINT fk_rails_7b28767f52 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: competencies fk_rails_7be14e9c53; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competencies
    ADD CONSTRAINT fk_rails_7be14e9c53 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: gate_passes fk_rails_7c1ee1aa5a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gate_passes
    ADD CONSTRAINT fk_rails_7c1ee1aa5a FOREIGN KEY (staff_id) REFERENCES public.staffs(id);


--
-- Name: notices fk_rails_7e3081eff2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notices
    ADD CONSTRAINT fk_rails_7e3081eff2 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: study_materials fk_rails_7fa1a0d11f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.study_materials
    ADD CONSTRAINT fk_rails_7fa1a0d11f FOREIGN KEY (staff_id) REFERENCES public.staffs(id);


--
-- Name: subjects fk_rails_8103a56a88; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT fk_rails_8103a56a88 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: hostel_allocations fk_rails_81f24e54b2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hostel_allocations
    ADD CONSTRAINT fk_rails_81f24e54b2 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: chat_messages fk_rails_82df60ae55; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT fk_rails_82df60ae55 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: sections fk_rails_833da4b940; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sections
    ADD CONSTRAINT fk_rails_833da4b940 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: exams fk_rails_89e12fe9db; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exams
    ADD CONSTRAINT fk_rails_89e12fe9db FOREIGN KEY (academic_year_id) REFERENCES public.academic_years(id);


--
-- Name: book_issues fk_rails_8a6797a02b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.book_issues
    ADD CONSTRAINT fk_rails_8a6797a02b FOREIGN KEY (book_id) REFERENCES public.books(id);


--
-- Name: payslips fk_rails_8ab29eef32; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payslips
    ADD CONSTRAINT fk_rails_8ab29eef32 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: role_assignments fk_rails_8ddd873ee0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_assignments
    ADD CONSTRAINT fk_rails_8ddd873ee0 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: guardians fk_rails_91de816a2a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guardians
    ADD CONSTRAINT fk_rails_91de816a2a FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: timetable_slots fk_rails_92c89184c6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.timetable_slots
    ADD CONSTRAINT fk_rails_92c89184c6 FOREIGN KEY (subject_id) REFERENCES public.subjects(id);


--
-- Name: subject_assignments fk_rails_94e641febb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subject_assignments
    ADD CONSTRAINT fk_rails_94e641febb FOREIGN KEY (staff_id) REFERENCES public.staffs(id);


--
-- Name: online_tests fk_rails_9582209843; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.online_tests
    ADD CONSTRAINT fk_rails_9582209843 FOREIGN KEY (grade_id) REFERENCES public.grades(id);


--
-- Name: competencies fk_rails_97d95ad371; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competencies
    ADD CONSTRAINT fk_rails_97d95ad371 FOREIGN KEY (subject_id) REFERENCES public.subjects(id);


--
-- Name: fee_invoices fk_rails_97dbd1b672; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fee_invoices
    ADD CONSTRAINT fk_rails_97dbd1b672 FOREIGN KEY (academic_year_id) REFERENCES public.academic_years(id);


--
-- Name: grades fk_rails_9803afc4f6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grades
    ADD CONSTRAINT fk_rails_9803afc4f6 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: gate_passes fk_rails_9ba3267816; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gate_passes
    ADD CONSTRAINT fk_rails_9ba3267816 FOREIGN KEY (student_id) REFERENCES public.students(id);


--
-- Name: book_issues fk_rails_9c351bd143; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.book_issues
    ADD CONSTRAINT fk_rails_9c351bd143 FOREIGN KEY (student_id) REFERENCES public.students(id);


--
-- Name: visitors fk_rails_9d41fe887d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.visitors
    ADD CONSTRAINT fk_rails_9d41fe887d FOREIGN KEY (meeting_id) REFERENCES public.staffs(id);


--
-- Name: admission_enquiries fk_rails_9e55aeac97; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admission_enquiries
    ADD CONSTRAINT fk_rails_9e55aeac97 FOREIGN KEY (assigned_to_id) REFERENCES public.users(id);


--
-- Name: transport_assignments fk_rails_a47fb8a7fa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transport_assignments
    ADD CONSTRAINT fk_rails_a47fb8a7fa FOREIGN KEY (student_id) REFERENCES public.students(id);


--
-- Name: ptm_slots fk_rails_a8f56f79c7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ptm_slots
    ADD CONSTRAINT fk_rails_a8f56f79c7 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: survey_questions fk_rails_aa7c176f23; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_questions
    ADD CONSTRAINT fk_rails_aa7c176f23 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: transport_routes fk_rails_afb3d500a0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transport_routes
    ADD CONSTRAINT fk_rails_afb3d500a0 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: survey_responses fk_rails_b0f344463a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_responses
    ADD CONSTRAINT fk_rails_b0f344463a FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: conversations fk_rails_b453318abb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT fk_rails_b453318abb FOREIGN KEY (staff_id) REFERENCES public.staffs(id);


--
-- Name: online_tests fk_rails_b6ad68c670; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.online_tests
    ADD CONSTRAINT fk_rails_b6ad68c670 FOREIGN KEY (staff_id) REFERENCES public.staffs(id);


--
-- Name: payslips fk_rails_b77d37263d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payslips
    ADD CONSTRAINT fk_rails_b77d37263d FOREIGN KEY (staff_id) REFERENCES public.staffs(id);


--
-- Name: fee_payments fk_rails_b99a03c31f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fee_payments
    ADD CONSTRAINT fk_rails_b99a03c31f FOREIGN KEY (fee_invoice_id) REFERENCES public.fee_invoices(id);


--
-- Name: sections fk_rails_ba0b8f1801; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sections
    ADD CONSTRAINT fk_rails_ba0b8f1801 FOREIGN KEY (class_teacher_id) REFERENCES public.staffs(id);


--
-- Name: ptm_meetings fk_rails_bb388ea6e2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ptm_meetings
    ADD CONSTRAINT fk_rails_bb388ea6e2 FOREIGN KEY (section_id) REFERENCES public.sections(id);


--
-- Name: gate_passes fk_rails_bb89bbbda8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gate_passes
    ADD CONSTRAINT fk_rails_bb89bbbda8 FOREIGN KEY (approved_by_id) REFERENCES public.users(id);


--
-- Name: greeting_campaigns fk_rails_bbc2672aa1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.greeting_campaigns
    ADD CONSTRAINT fk_rails_bbc2672aa1 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: ptm_slots fk_rails_bc45edb99d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ptm_slots
    ADD CONSTRAINT fk_rails_bc45edb99d FOREIGN KEY (ptm_meeting_id) REFERENCES public.ptm_meetings(id);


--
-- Name: homeworks fk_rails_bf610ddb0f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.homeworks
    ADD CONSTRAINT fk_rails_bf610ddb0f FOREIGN KEY (section_id) REFERENCES public.sections(id);


--
-- Name: web_pages fk_rails_c130f13ef2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.web_pages
    ADD CONSTRAINT fk_rails_c130f13ef2 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: live_classes fk_rails_c32149e4bb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.live_classes
    ADD CONSTRAINT fk_rails_c32149e4bb FOREIGN KEY (subject_id) REFERENCES public.subjects(id);


--
-- Name: transport_assignments fk_rails_c3d3de1b6b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transport_assignments
    ADD CONSTRAINT fk_rails_c3d3de1b6b FOREIGN KEY (route_stop_id) REFERENCES public.route_stops(id);


--
-- Name: gate_passes fk_rails_c498af047b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gate_passes
    ADD CONSTRAINT fk_rails_c498af047b FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: homework_submissions fk_rails_c4e9aea156; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.homework_submissions
    ADD CONSTRAINT fk_rails_c4e9aea156 FOREIGN KEY (student_id) REFERENCES public.students(id);


--
-- Name: conversations fk_rails_c4fdc13de0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT fk_rails_c4fdc13de0 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: issued_certificates fk_rails_c5cb9d496d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.issued_certificates
    ADD CONSTRAINT fk_rails_c5cb9d496d FOREIGN KEY (student_id) REFERENCES public.students(id);


--
-- Name: fee_structures fk_rails_cd7cf65377; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fee_structures
    ADD CONSTRAINT fk_rails_cd7cf65377 FOREIGN KEY (grade_id) REFERENCES public.grades(id);


--
-- Name: survey_questions fk_rails_d0558bfd89; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.survey_questions
    ADD CONSTRAINT fk_rails_d0558bfd89 FOREIGN KEY (survey_id) REFERENCES public.surveys(id);


--
-- Name: certificate_templates fk_rails_d08eabc5ed; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.certificate_templates
    ADD CONSTRAINT fk_rails_d08eabc5ed FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: competency_scores fk_rails_d0d9466b3d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competency_scores
    ADD CONSTRAINT fk_rails_d0d9466b3d FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: attendances fk_rails_d1a9c7df43; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendances
    ADD CONSTRAINT fk_rails_d1a9c7df43 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: message_logs fk_rails_d35498a84d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.message_logs
    ADD CONSTRAINT fk_rails_d35498a84d FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: route_stops fk_rails_d6208c0847; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.route_stops
    ADD CONSTRAINT fk_rails_d6208c0847 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: fee_invoice_items fk_rails_d6b39655f7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fee_invoice_items
    ADD CONSTRAINT fk_rails_d6b39655f7 FOREIGN KEY (fee_invoice_id) REFERENCES public.fee_invoices(id);


--
-- Name: competency_scores fk_rails_d7797402f8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competency_scores
    ADD CONSTRAINT fk_rails_d7797402f8 FOREIGN KEY (competency_id) REFERENCES public.competencies(id);


--
-- Name: study_materials fk_rails_d7ac52445a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.study_materials
    ADD CONSTRAINT fk_rails_d7ac52445a FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: message_templates fk_rails_d7bfadd7b6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.message_templates
    ADD CONSTRAINT fk_rails_d7bfadd7b6 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: lesson_plans fk_rails_d8b0823155; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lesson_plans
    ADD CONSTRAINT fk_rails_d8b0823155 FOREIGN KEY (staff_id) REFERENCES public.staffs(id);


--
-- Name: biometric_punches fk_rails_d8cff97f87; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.biometric_punches
    ADD CONSTRAINT fk_rails_d8cff97f87 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: staffs fk_rails_dc073ad4c2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staffs
    ADD CONSTRAINT fk_rails_dc073ad4c2 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: vehicle_locations fk_rails_dc77070872; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicle_locations
    ADD CONSTRAINT fk_rails_dc77070872 FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(id);


--
-- Name: exam_results fk_rails_dd435496ed; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exam_results
    ADD CONSTRAINT fk_rails_dd435496ed FOREIGN KEY (exam_schedule_id) REFERENCES public.exam_schedules(id);


--
-- Name: attendances fk_rails_de1a861ed4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attendances
    ADD CONSTRAINT fk_rails_de1a861ed4 FOREIGN KEY (marked_by_id) REFERENCES public.users(id);


--
-- Name: timetable_slots fk_rails_df541ffe75; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.timetable_slots
    ADD CONSTRAINT fk_rails_df541ffe75 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: evaluations fk_rails_dfcb5d1138; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.evaluations
    ADD CONSTRAINT fk_rails_dfcb5d1138 FOREIGN KEY (evaluator_id) REFERENCES public.staffs(id);


--
-- Name: biometric_punches fk_rails_e233c644cb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.biometric_punches
    ADD CONSTRAINT fk_rails_e233c644cb FOREIGN KEY (biometric_device_id) REFERENCES public.biometric_devices(id);


--
-- Name: exam_schedules fk_rails_e30b637d55; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exam_schedules
    ADD CONSTRAINT fk_rails_e30b637d55 FOREIGN KEY (subject_id) REFERENCES public.subjects(id);


--
-- Name: staffs fk_rails_e39f89aab8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staffs
    ADD CONSTRAINT fk_rails_e39f89aab8 FOREIGN KEY (department_id) REFERENCES public.departments(id);


--
-- Name: biometric_devices fk_rails_e4af08f995; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.biometric_devices
    ADD CONSTRAINT fk_rails_e4af08f995 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: role_assignments fk_rails_e4bfc1cd2c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_assignments
    ADD CONSTRAINT fk_rails_e4bfc1cd2c FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: stock_movements fk_rails_e77ec360f2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_movements
    ADD CONSTRAINT fk_rails_e77ec360f2 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: users fk_rails_e7d0538b2c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_e7d0538b2c FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: hostels fk_rails_e7e0512093; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hostels
    ADD CONSTRAINT fk_rails_e7e0512093 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: transport_routes fk_rails_e9c4258145; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transport_routes
    ADD CONSTRAINT fk_rails_e9c4258145 FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(id);


--
-- Name: kb_articles fk_rails_ebd1b1ab74; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kb_articles
    ADD CONSTRAINT fk_rails_ebd1b1ab74 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: test_attempts fk_rails_ec8f27534c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_attempts
    ADD CONSTRAINT fk_rails_ec8f27534c FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: enrollments fk_rails_f01c555e06; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT fk_rails_f01c555e06 FOREIGN KEY (student_id) REFERENCES public.students(id);


--
-- Name: hostel_allocations fk_rails_f170eff26e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hostel_allocations
    ADD CONSTRAINT fk_rails_f170eff26e FOREIGN KEY (student_id) REFERENCES public.students(id);


--
-- Name: homeworks fk_rails_f1839f6006; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.homeworks
    ADD CONSTRAINT fk_rails_f1839f6006 FOREIGN KEY (subject_id) REFERENCES public.subjects(id);


--
-- Name: stock_movements fk_rails_f1ac0130cf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stock_movements
    ADD CONSTRAINT fk_rails_f1ac0130cf FOREIGN KEY (recorded_by_id) REFERENCES public.users(id);


--
-- Name: hostels fk_rails_f2163d52d9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hostels
    ADD CONSTRAINT fk_rails_f2163d52d9 FOREIGN KEY (warden_id) REFERENCES public.staffs(id);


--
-- Name: notices fk_rails_f26b370db5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notices
    ADD CONSTRAINT fk_rails_f26b370db5 FOREIGN KEY (section_id) REFERENCES public.sections(id);


--
-- Name: homeworks fk_rails_f31683995b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.homeworks
    ADD CONSTRAINT fk_rails_f31683995b FOREIGN KEY (staff_id) REFERENCES public.staffs(id);


--
-- Name: enrollments fk_rails_f5c1ae1385; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enrollments
    ADD CONSTRAINT fk_rails_f5c1ae1385 FOREIGN KEY (academic_year_id) REFERENCES public.academic_years(id);


--
-- Name: book_issues fk_rails_f8fbb42e72; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.book_issues
    ADD CONSTRAINT fk_rails_f8fbb42e72 FOREIGN KEY (school_id) REFERENCES public.schools(id);


--
-- Name: test_questions fk_rails_fa82487007; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_questions
    ADD CONSTRAINT fk_rails_fa82487007 FOREIGN KEY (online_test_id) REFERENCES public.online_tests(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20260910130000'),
('20260910120000'),
('20260910110000'),
('20260910100000'),
('20260910090000'),
('20260909170500'),
('20260909165928'),
('20260909165927'),
('20260909165926'),
('20260909165925'),
('20260909165924'),
('20260909165923');

