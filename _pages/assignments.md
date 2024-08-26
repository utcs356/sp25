---
layout: assignments
permalink: /assignments/
title: Programming Assignments
---

The course will be quite hands on. We will have five programming assignments. In
general, the programming assignments are to be done in groups of 2. Each project
will be due 2-3 weeks after it is assigned. 

Prior experience has shown that students who begin projects shortly after they
are assigned are more likely to succeed. Projects submitted after the day and
time they are due will be penalized 10% of the total points of the assignment
per day, unless you have made prior arrangements with me due to extenuating
circumstances.

You should pick your own group members for your projects, but you may use the
[Ed discussion](https://edstem.org/us/courses/50367) for the course to help find
group members. You have the option of switching group members between projects
but checking with the TA and instructor first. Completing a project individually
requires professor's prior approval.

All code and results you submit must be the original work of your group.
Cheating and plagiarism will not be tolerated and will be dealt with in
accordance with the [University of Texas policies and
procedures](https://deanofstudents.utexas.edu/conduct/index.php).


{% for item in site.data.assignments %}
{% if item.release_date %}
{% assign assignment = item %}
{% assign link = '/assignments/assignment' | append: assignment.number %}


<tr>
    <th scope="row">{{ assignment.number }}</th>
    <th scope="row"><a href = "{{ link | relative_url }}">{{ assignment.title }}</a></th>
    <th scope="row">{{ assignment.release_date }}</th>
    <th scope="row">{{ assignment.due_date }}</th>
</tr>
{% endif %}
{% endfor %}
