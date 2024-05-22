-- Number of attendees for each conference
SELECT p.id, count(distinct r.conference) as num_conference
FROM Person p LEFT JOIN Registration r ON p.id = r.attendee AND r.has_paid = true
GROUP BY p.id;

-- Assume that once a person registers and pays, they will attend the event