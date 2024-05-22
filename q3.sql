-- Number of accepted submissions for each conference
DROP VIEW IF EXISTS ConferenceSubmissionAccepted CASCADE;
CREATE VIEW ConferenceSubmissionAccepted AS
SELECT s.conference, count(s.id) as num_accept
FROM AcceptedSubmission acs JOIN Submission s ON acs.id = s.id
GROUP BY s.conference;

SELECT conference, num_accept
FROM ConferenceSubmissionAccepted
WHERE num_accept >= (
    SELECT max(num_accept) FROM ConferenceSubmissionAccepted);
