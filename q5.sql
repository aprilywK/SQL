-- Number of paper submissions for each paper session
DROP VIEW IF EXISTS SessionPaperNumber;
CREATE VIEW SessionPaperNumber AS
SELECT s.conference, COUNT(spa.submission) as num_papers,
       COUNT(DISTINCT spa.session) as num_paper_sessions
FROM SessionPaper spa
         JOIN Submission s ON spa.submission = s.id
WHERE s.stype = 'paper'
GROUP BY s.conference;

-- Number of poster submissions for each poster session
DROP VIEW IF EXISTS SessionPosterNumber;
CREATE VIEW SessionPosterNumber AS
SELECT s.conference, COUNT(spo.submission) as num_posters,
       COUNT(DISTINCT spo.session) as num_poster_sessions
FROM SessionPoster spo
         JOIN Submission s ON spo.submission = s.id
WHERE s.stype = 'poster'
GROUP BY s.conference;

SELECT
    c.id as conference_id,
    COALESCE(spn.avg_papers, 0) as avg_papers_per_session,
    COALESCE(spo.avg_posters, 0) as avg_posters_per_session
FROM
    Conference c
        LEFT JOIN (SELECT conference, num_papers::FLOAT
        / num_paper_sessions as avg_papers FROM SessionPaperNumber) spn
            ON c.id = spn.conference
        LEFT JOIN (SELECT conference, num_posters::FLOAT
        / num_poster_sessions as avg_posters FROM SessionPosterNumber) spo
            ON c.id = spo.conference;
