-- CSC343, Introduction to Databases
-- Assignment 3
-- Prepared by Lovina Lokeswara, Yewon Kim

-- Some constraints that are not expressed in our domain description exist 
-- because they need to be checked through subquery as we need information 
-- (columns) from other relation
-- 
-- However, psql doesn't allow subquery in a check constraint unlike the SQL 
-- standard. Thus, all constraints that are described below cannot be described 
-- because they need information from other relation and have to use subquery 
-- in order to appropriately check the constraint

-- Submission
-- * Constraint that previously accepted submissions cannot be submitted again. 
-- A submission is considered the same if they have the same title, authors, 
-- and type. This cannot be applied because we need
-- 1. AcceptedSubmission(submission), Submission(id, conference), 
-- Conference(start_date) to get the list of accepted submission along with 
-- the dates of conference the submission are already accepted
-- 2. Submission(id, title, stype) and SubmissionAuthor(submission, author) 
-- to find the information of those submissions that are already accepted
-- 3. Check if the newly entered submission does not have the same details 
-- as the submissions that are already accepted

-- SubmissionAuthor
-- * Constraint to have at least one author per paper submission to be a 
-- reviewer: cannot be applied since we need the information 
-- 1. Submission(stype) and check if the author is in Reviewer(reviewer). 
-- 2. We cannot enforce FOREIGN KEY constraint because not every author
-- must be in Reviewer(reviewer)

-- Registration & AcceptedSubmission:
-- For Registration, we made an assumption on registration form that it is
-- possible to fill out them first without paying and registration is
-- successful if the attendee pays before the deadline of the registration.
-- * Constraint to have at least one author on every accepted submission 
-- to be registered in the conference: cannot be applied since we need 
-- 1. Registration(attendee, conference) and 
-- 2. AcceptedSubmission(submission), Submission(id, conference), 
-- SubmissionAuthor(submission, author) to gather the list of authors for 
-- the accepted submission in that conference
-- 3. Then do cross join, except (for sets), and select to find out if 
-- at least one author per accepted submission is in registration

-- ConferenceChair
-- * Constraint to be the chair is to be the committee for that conference 
-- at least twice before, unless the conference is new: cannot be applied 
-- since we need 
-- 1. OrganizingCommittee(conference, committee)
-- 2. Conference(id, name)
-- 3. Then find if the ConferenceChair(chair) is in OrganizingCommittee at 
-- least twice for a conference that has been held more than twice previously

-- Reviewer
-- Assumption made that one reviewer can review multiple submission as long as
-- they are not their own submission.

-- Review
-- * Constraint is to not allow review assignment for reviewers who are author, 
-- co-author, of the submission or in the same organization with the author: 
-- cannot be applied since we need 
-- 1. SubmissionAuthor(submission, author), to check if the reviewer is 
-- an author or co-author
-- 2. Person(id, organization), SubmissionAuthor(submission, author) to check 
-- if the reviewer is from the same organization as one of the authors

-- AcceptedSubmission
-- * Constraint to have at least 3 reviews and at least 1 'accept' result: 
-- cannot be applied because we need 
-- 1. Review(submission, result) to check the result and the count of 
-- review for the particular submission

-- Session
-- * Constraint on the presentation schedule that the multiple presentations
-- can run at the same time but no author can have two presentations at the
-- same time, with one exception, where an author can have one paper and
-- poster at the same time, as long as they are not the sole author on
-- either of them: Cannot be applied since we need information on
-- 1. SubmissionAuthor to check if there are multiple author for the
-- submission.
-- 2. Check SessionPaper and Session to see if there is any
-- submission with a sole author running for different sessions at
-- the same time.

-- SessionChairPaper
-- For this table, we made an assumption on that there can be more than
-- one chair for a session.
-- * Constraint for the session chair to attend the conference, 
-- not an author on papers in the session, and not have something scheduled 
-- at the same time (workshops or presentations): cannot be applied since
-- we need information 
-- 1. Registration(conference, attendee) to know if the chair attends the 
-- conference
-- 2. SubmissionAuthor and Session(submission) to know if the chair is 
-- an author on papers in the session
-- 3. WorkshopRegistration(workshop, participant) and 
-- Workshop(id, start_time, end_time) to know if the chair registers
-- same time for workshop 
-- 4. SessionPaper(submission, start_time, end_time), 
-- SessionPoster(submission), Session(stype, start_time, end_time) and 
-- SubmissionAuthor(submission, author) to know if the chair has a submission 
-- presentation scheduled
-- * Constraint to have a session chair for paper sessions only: cannot 
-- be expressed more specifically because we need
-- 1. To filter Session(stype) where stype = 'paper'

-- Workshop
-- * Constraint for the workshop facilitator.
-- This cannot be applied since we have to WorkshopFacilitator table,
-- but this can only be used after Workshop table is made. Thus,
-- both tables refer each other at the same time, resulting in
-- a conflict. 

-- START SCHEMA --

DROP SCHEMA IF EXISTS A3Conference CASCADE;
CREATE SCHEMA A3Conference;
SET SEARCH_PATH TO A3Conference;

CREATE TYPE A3Conference.submission_type AS ENUM (
	'paper', 'poster'
);
CREATE TYPE A3Conference.result_type AS ENUM (
	'accept', 'reject'
);

-- A conference
CREATE TABLE IF NOT EXISTS Conference (
    -- The id of a conference.
	id INT PRIMARY KEY,
    -- The name of a conference.
	name TEXT NOT NULL,
    -- The location of a conference.
	location TEXT NOT NULL,
	-- The start date of a conference
    start_date DATE NOT NULL,
    -- The end date of a conference
    end_date DATE NOT NULL,
    CONSTRAINT proper_date CHECK (start_date <= end_date)
);

-- A submission.
CREATE TABLE IF NOT EXISTS Submission (
    -- The id of a submission.
	id INT PRIMARY KEY,
    -- The title of a submission.
	title TEXT NOT NULL,
    -- The type of a submission ('paper' or 'poster')
    stype submission_type NOT NULL,
    -- The conference when a submission is submitted.
    conference INT NOT NULL,
    -- The id of the conference they are presented.
    FOREIGN KEY (conference) REFERENCES Conference(id),
	CONSTRAINT check_stype CHECK (stype IN ('paper', 'poster'))
);

-- An organization.
CREATE TABLE IF NOT EXISTS Organization (
    -- The id of an organization.
	id INT PRIMARY KEY,
    -- The name of an organization.
	name TEXT NOT NULL
);

-- A Person in the database, this includes author, registrants, and 
-- other possible roles
CREATE TABLE IF NOT EXISTS Person (
    -- The id of a person
	id INT PRIMARY KEY,
    -- The first and last name of a person.
	name TEXT NOT NULL,
    -- Their status whether they are a student or not.
	is_student BOOLEAN NOT NULL,
    -- Their contact info.
    contact_info TEXT NOT NULL,
    -- The organization they are associated with.
	organization INT NOT NULL,

	FOREIGN KEY (organization) REFERENCES Organization(id)
);

-- An author to a submission.
CREATE TABLE IF NOT EXISTS SubmissionAuthor (
    -- The id of a submission.
    submission INT NOT NULL,
    -- The id of an author of the submission.
	author INT NOT NULL,
    -- The order of an author.
	order_author INT NOT NULL,
	PRIMARY KEY (submission, author),
    FOREIGN KEY (submission) REFERENCES Submission(id),
	FOREIGN KEY (author) REFERENCES Person(id)
);

-- Registration for conference attendees.
CREATE TABLE IF NOT EXISTS Registration (
    -- The id of a registration.
	id INT NOT NULL,
	-- The id of a conference the attendee registered.
	conference INT NOT NULL,
    -- The id of a attendee.
	attendee INT NOT NULL,
	-- The status whether the attendee has paid or not.
    has_paid BOOLEAN NOT NULL,

	PRIMARY KEY (conference, attendee),
	FOREIGN KEY (conference) REFERENCES Conference(id),
    FOREIGN KEY (attendee) REFERENCES Person(id)
);

-- A committee that organizes the conference.
CREATE TABLE IF NOT EXISTS OrganizingCommittee (
    -- The id of a conference they're organizing.
	conference INT NOT NULL,
	-- The id of a commitee.
	committee INT NOT NULL,

    PRIMARY KEY (committee, conference),
	FOREIGN KEY (committee) REFERENCES Person(id),
    FOREIGN KEY (conference) REFERENCES Conference(id),
	FOREIGN KEY (conference, committee) REFERENCES
		Registration (conference, attendee)
	-- NOTE: The organizing committee of that conference must register
	-- for the conference
);

-- A conference chair.
CREATE TABLE IF NOT EXISTS ConferenceChair (
    -- The id of a conference.
	conference INT NOT NULL,
	-- The id of a conference chair.
	chair INT NOT NULL,

	PRIMARY KEY (conference, chair),
	FOREIGN KEY (conference) REFERENCES Conference(id),
    FOREIGN KEY (chair) REFERENCES Person(id)
);

-- A reviewer.
CREATE TABLE IF NOT EXISTS Reviewer (
    -- The id of a reviewer.
    id INT NOT NULL,
    -- The id of the person from the Person database, whose role is a reviewer.
    reviewer INT NOT NULL,

	PRIMARY KEY (id),
    FOREIGN KEY (reviewer) REFERENCES Person(id)
	-- Assumption: Reviewer can be someone who is non-author
);

-- A review of a submission and its result.
CREATE TABLE IF NOT EXISTS Review (
    -- The id of a submission that will be reviewed.
	submission INT NOT NULL,
	-- The id of a reviewer.
	reviewer INT NOT NULL,
	-- The type of the result, either will be accept or reject.
	result result_type,
	-- result can be NULL if the decision has not been made by the reviewer

    UNIQUE (submission, reviewer),
    FOREIGN KEY (submission) REFERENCES Submission(id),
    FOREIGN KEY (reviewer) REFERENCES Reviewer(id)
);

-- An accepted submission.
CREATE TABLE IF NOT EXISTS AcceptedSubmission (
    -- The id of an accepted submission.
	id INT PRIMARY KEY,

	FOREIGN KEY (id) REFERENCES Submission(id)
);

-- A session.
CREATE TABLE IF NOT EXISTS Session (
    -- The id of a session.
	id INT PRIMARY KEY,
	-- The id of a conference.
	conference INT NOT NULL,
	-- The start time of a session.
    start_time TIMESTAMP NOT NULL,
    -- The end time of a session.
    end_time TIMESTAMP NOT NULL,

    CONSTRAINT start_before_end CHECK (start_time < end_time),
    FOREIGN KEY (conference) REFERENCES Conference(id)
);

-- A paper session.
CREATE TABLE IF NOT EXISTS SessionPaper (
    -- The id of a session.
	session INT NOT NULL,
	-- The id of a submission.
	submission INT NOT NULL,
	-- The start time of a session.
    start_time TIMESTAMP NOT NULL,
    -- The end time of a session.
    end_time TIMESTAMP NOT NULL,

	PRIMARY KEY (session, submission),
    CONSTRAINT start_before_end CHECK (start_time < end_time),
	FOREIGN KEY (session) REFERENCES Session(id),
    FOREIGN KEY (submission) REFERENCES AcceptedSubmission(id)
);

-- A poster session.
CREATE TABLE IF NOT EXISTS SessionPoster (
    -- The id of a session.
	session INT NOT NULL,
    -- The id of a submission.
	submission INT NOT NULL,

	PRIMARY KEY (session, submission),
	FOREIGN KEY (session) REFERENCES Session(id),
    FOREIGN KEY (submission) REFERENCES AcceptedSubmission(id)
	-- NOTE: A poster doesn't have its own start time, 
	-- it follows the overall session's timeline so no time variable
);

-- A paper session's chair.
CREATE TABLE IF NOT EXISTS SessionChairPaper (
    -- The id of a session.
	session INT NOT NULL,
    -- The id of a chair.
	chair INT NOT NULL,

	FOREIGN KEY (session) REFERENCES Session(id),
    FOREIGN KEY (chair) REFERENCES Person(id),
	PRIMARY KEY (session, chair)
);

CREATE TABLE IF NOT EXISTS ConferenceFee (
    -- The id of a conference.
	conference INT PRIMARY KEY,
    -- The registration fee for a regular attendees.
	regular_fee INT NOT NULL,
	-- The registration fee for a student attendees.
	student_fee INT NOT NULL,

	CONSTRAINT check_student_fee_is_lower CHECK (regular_fee > student_fee)
);

CREATE TABLE IF NOT EXISTS Workshop (
    -- The id of a workshop.
	id INT NOT NULL PRIMARY KEY,
    -- The id of a conference.
	conference INT NOT NULL,
    -- The title of a workshop.
	title TEXT NOT NULL,
    -- The fee of a workshop.
	fee DECIMAL(10,2) NOT NULL,
    -- The start time of a workshop.
    start_time TIMESTAMP NOT NULL,
    -- The end time of a workshop.
    end_time TIMESTAMP NOT NULL,

    CONSTRAINT workshop_times CHECK (start_time < end_time),
    FOREIGN KEY (conference) REFERENCES Conference(id)
);

-- Workshop Registration.
CREATE TABLE IF NOT EXISTS WorkshopRegistration (
    --  The id of a workshop.
    workshop INT NOT NULL,
    -- The id of a participant.
    participant INT NOT NULL,
    -- The status whether the participant has paid.
    paid BOOLEAN NOT NULL,

    PRIMARY KEY (workshop, participant),
    FOREIGN KEY (workshop) REFERENCES Workshop(id),
    FOREIGN KEY (participant) REFERENCES Person(id)
);

-- A workshop facilitator.
CREATE TABLE IF NOT EXISTS WorkshopFacilitator (
    --  The id of a workshop.
    workshop INT NOT NULL,
    -- The id of a facilitator.
    facilitator INTEGER NOT NULL,

    PRIMARY KEY (workshop, facilitator),
    FOREIGN KEY (workshop) REFERENCES Workshop(id),
    FOREIGN KEY (facilitator) REFERENCES Person(id)
);
