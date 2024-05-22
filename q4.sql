-- Title and type of the accepted submissions
DROP VIEW IF EXISTS SubmissionAcceptedInfo CASCADE;
CREATE VIEW SubmissionAcceptedInfo AS
SELECT S.title, S.stype
FROM Submission AS S JOIN AcceptedSubmission AS A ON S.id = A.id;

-- Number of attempts before it was accepted
DROP VIEW IF EXISTS SubmissionAttempts CASCADE;
CREATE VIEW SubmissionAttempts AS
SELECT S.title, S.stype, COUNT(S.id) AS attempts
FROM Submission AS S
WHERE EXISTS (
    SELECT * FROM SubmissionAcceptedInfo AS SAI 
    WHERE S.title = SAI.title AND S.stype = SAI.stype)
GROUP BY S.title, S.stype;

-- Maximum number of attempts before it was accepted
DROP VIEW IF EXISTS MaxAttempts CASCADE;
CREATE VIEW MaxAttempts AS
SELECT MAX(attempts) AS max_attempts
FROM SubmissionAttempts;

SELECT SA.title, SA.stype, SA.attempts - 1 as attempts_before_accepted
FROM SubmissionAttempts AS SA, MaxAttempts AS MA
WHERE SA.attempts = MA.max_attempts;