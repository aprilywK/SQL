-- Number of accepted submissions for each conference
DROP VIEW IF EXISTS ConferenceSubmissionAccepted CASCADE;
CREATE VIEW ConferenceSubmissionAccepted AS
SELECT s.conference, CAST(count(accs.id) as float) as count_accept
FROM AcceptedSubmission accs JOIN Submission s ON accs.id = s.id
GROUP BY s.conference;

-- Total number of submissions for each conference
DROP VIEW IF EXISTS ConferenceSubmission CASCADE;
CREATE VIEW ConferenceSubmission AS
SELECT s.conference, count(s.id) as count
FROM Submission s
GROUP BY s.conference;

-- Assume conference at most is held once a year and year is taken from 
-- the start date
DROP VIEW IF EXISTS ConferenceYear CASCADE;
CREATE VIEW ConferenceYear AS
SELECT id, name, EXTRACT(YEAR FROM start_date) as year
FROM Conference;

SELECT cy.id, cy.name, cy.year, count_accept / count as acceptance_rate
FROM ConferenceYear cy  
    LEFT JOIN ConferenceSubmission cs ON cy.id = cs.conference
    LEFT JOIN ConferenceSubmissionAccepted csa ON cy.id = csa.conference;
