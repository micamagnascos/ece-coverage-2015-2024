# Speaking script — short-term effects, progress update (October 2026)

Target: ~25 minutes, 24 main slides. Slides 3–13 are unchanged from last time; go faster there. The new material starts at slide 14.

---

### Slide 1 — Title

Thank you all for making the time. Today is a progress update on the short-run project: what happens to mothers when a public preschool opens in their neighborhood. Since last time, we have the first full set of results: first stage, fertility, and labor market.

### Slide 2 — Where we are

Here's the whole talk in one slide.

On the left, a reminder of what we do: 447 neighborhood units that open their first public preschool between 2015 and 2024, compared with about four thousand that never get one, using a Sun-Abraham event study.

On the right, what we find. The first stage is now clear: enrollment goes up by about two percentage points, from 33 to 35 percent, with no pre-trends. One cohort, 2015, shows almost no effect, and without it the first stage is about three points. So far, there is no effect on fertility. Formal employment rises by about one point from the fourth year on, although pre-trends deserve caution. Earnings show a suggestive increase of two to four percent: not significant yet, but these are not our final estimates. Months worked, so far, don't change. And a cleaner control group gives the same results.

*Transition:* I'll go quickly through the design, since you've seen it, and spend most of the time on the results.

### Slide 3 — Research question

The question is what happens to mothers' labor supply and fertility when public early childhood education expands. The evidence is mixed, and most recent Latin American evidence comes from lotteries. Our contribution is to use variation at the UV level, the official sub-municipal unit, which gives a sharper measure of exposure, and to add fertility as a second margin.

### Slide 4 — Chilean context

More than seven hundred new public preschools opened between 2015 and 2024. For ages zero to four, JUNJI and Integra are the main providers, which is why we focus on them.

### Slide 5 — Identification design

A staggered difference-in-differences with an event study. A UV is treated the year it opens its first public preschool. We compare changes in those UVs against UVs that never get one. This is an intent-to-treat effect of access.

### Slide 6 — Treatment definition

We exclude UVs that already had a preschool in 2014, so we identify the effect of the first preschool, going from zero to one: 447 treated versus 4,145 never-treated.

### Slide 7 — Treatment cohorts

Most openings happen early: the 2015 cohort alone is forty percent of treated UVs. Keep that in mind. This cohort only has one pre-period, and we'll come back to it, because it turns out to matter.

### Slide 8 — Specification

UV and year fixed effects, event-time dummies relative to the year before opening. Our main estimator is Sun-Abraham with never-treated UVs as controls. TWFE is shown only as a reference.

### Slides 9 to 12 — Data, geography and samples

Everything comes from administrative registries linked at the individual level. Every preschool and every woman is mapped to 2024 UV boundaries. Each outcome has its own sample: women 18 to 49 for fertility, mothers with a child under five for the labor market, and their children for enrollment.

### Slide 13 — Balance

In 2014, mothers in treated and never-treated UVs look alike. The one real difference is UV size: treated UVs are larger, which UV fixed effects absorb.

*Transition:* Now the results, starting with the first stage.

### Slide 14 — First stage event study

This is the enrollment event study. Blue is Sun-Abraham, orange is TWFE. Our main estimate is the weighted one, on the right, because it gives the effect for the average child.

Enrollment goes up by about two percentage points in the opening year and stays there. On a base of 33 percent, that's about six percent. Unweighted, it's about three points, because larger UVs move less with the same number of new places. Before the opening, all coefficients are small and not significant.

Years seven to nine fall a bit, but that's composition, not a fading effect: only the earliest cohorts are observed that far out, mostly 2015.

In words: a new preschool raises enrollment from 33 to 35 percent. That's about three more children enrolled per UV. It's clear, but small, far below a preschool's capacity.

*If asked:*
- *"Why is it so small?"* → Five candidates:
  1. **The 2015 cohort**: almost half of treated UVs, with an effect close to zero. Possibly a registration error, with preschools that already existed in 2014. Coming up in two slides.
  2. **Weighting**: the same new places in a larger UV move the rate less, and treated UVs are about twice as large.
  3. **The denominator**: it includes four-year-olds, who are mostly enrolled already.
  4. **Substitution**: the new preschool can fill with children who were already enrolled somewhere else, so the net rate barely changes.
  5. **Spillovers to controls**: children from control UVs enrolling next door. We tested this and ruled it out (slides 17–18).
  6. **Mothers may not use the preschool in their own UV**: they may choose one near work, or on the way to work. Then the new preschool fills with children from other UVs, and enrollment of children living in the treated UV barely moves.
- *"How would you test that?"* → In the future: the enrollment records tell us which preschool each child attends. So we can look at enrollment in the new preschool itself, see where its children live, and see which preschools the mothers of each UV actually use.
- *"Why is weighted smaller than unweighted?"* → Weighted is the average child, unweighted the average UV. Treated UVs are about twice as large.

### Slide 15 — By child age

By age, the effect is largest at ages two to three: about four points, immediate and stable. At ages zero to one it's small in points but the largest relative to its base. Age four also has a positive effect. One caution: ages are measured at different points in time across datasets, so some children may fall in the wrong group. We'll check that.

So enrollment rises at all ages, most at ages two to three.

*If asked:*
- *"What do you mean by different points in time?"* → Age groups come from the year of birth, while enrollment is measured in June. So a child's age in the enrollment data may not match the group we assign.

### Slide 16 — The 2015 cohort

This is the main open issue. Each panel shows the enrollment gap between one opening cohort and the never-treated UVs, year by year. The effect is how much that gap changes after the opening, the dashed line.

Look at 2015. It's the largest cohort, 172 UVs, forty percent of treated, and its gap barely moves: less than one point. Compare with 2017 or 2019, where the gap jumps right at the opening. Because 2015 is so large, it pulls the average effect down. When we drop it, the first stage goes from 1.9 to about three points, and it's stable over the whole period. That's preliminary, I still need the standard errors.

Why would 2015 be so small? It may be a data issue. My hypothesis is a registration error at the edge of the panel: preschools that already existed in 2014 but are recorded as opening in 2015. So the next step is to carefully review the coverage data provided by JUNJI and Integra.

*If asked:*
- *"And if the 2015 openings are real?"* → Then the effect differs by cohort, and two points is the right average.
- *"Why would 2015 be different?"* → It's the first year of the panel and the start of the Bachelet expansion. Openings recorded in the first year are the most likely to be recording artifacts.
- *"What about 2016? The gap rises before the opening."* → Yes, from 2.9 to 4.2 points in the year before. We need to check its opening dates too.

### Slide 17 — A cleaner control group: motivation

Pedro, this is related to something you suggested. Our design assumes that opening a preschool in one UV doesn't affect the others. A spillover breaks that: a preschool opens next door, some children from a never-treated UV enroll there, and enrollment in the control group goes up too. Since the effect is the difference between treated and controls, part of the true effect gets subtracted, and we underestimate it.

To test this, we built a map of neighbors. Two UVs are neighbors if they share a border or a corner, using 2024 boundaries. For every UV, we flag whether a neighbor opened a preschool between 2015 and 2024, and whether a neighbor had a preschool in any year. This example is a control UV in La Cisterna. It has nine neighbors, and five of them open a preschool during the period. That's the kind of control we want to remove.

One limitation: this only captures proximity to home. If mothers take their children to a preschool near work, spillovers can reach UVs that are not adjacent.

*If asked:*
- *"Why does a neighbor that opens matter more than one that already had a preschool?"* → A neighbor's preschool that existed in 2014 is there the whole period, so the UV fixed effects absorb it. Only a new opening changes the control over time.
- *"Only first-order neighbors?"* → Yes. A child going to a preschool two UVs away is not captured, and the flag says whether a neighbor ever opened, not since when.

### Slide 18 — Cleaner control: results

We tried three control groups. All never-treated UVs, which is our main one. UVs with no neighbor that opened a preschool between 2015 and 2024: about 2,150. And the strictest one: UVs with no neighboring preschool in any year: 652.

The idea was to find a larger first stage with cleaner controls. It didn't happen: the effect is the same with all three, around two points, with clean pre-trends.

The strictest group has a different problem: those UVs are very different. Their median area is 6.7 square kilometers, versus 1.5 for treated UVs. They're isolated, more rural areas, with lower enrollment. So the preferred clean control is the middle one, no neighbor that opened, and it gives 2.1 points, versus 1.9 with all never-treated.

So spillovers don't explain why the first stage is small.

*If asked:*
- *"Why not the middle group as main spec?"* → We can; the results are the same. A neighbor's preschool that already existed in 2014 is fixed, so the UV fixed effects absorb it. That's why the middle group is the conceptually right one.

### Slide 19 — Why is the first stage small?

To close the first stage: with the 2015 cohort and the cleaner control, I was trying to see whether the small effect was an artifact of the design. Dropping 2015 raises it somewhat; the cleaner control doesn't change it.

So I think the main reason is what our outcome measures. We look at whether children living in the treated UV are enrolled in any preschool. A new preschool only raises that if it takes local children who were not enrolled before. It doesn't, if local children were already enrolled somewhere else and just switch. And it doesn't, if mothers prefer a preschool in another UV, for example near their workplace: then the new places go to children from other UVs. In both cases, the new preschool can fill up while our outcome barely moves.

This is something we can look at in the future. The enrollment records tell us which preschool each child attends. So we can see who fills the new preschool, where those children live, and which preschools local mothers actually use.

*If asked:*
- *"Other reasons?"* → Two smaller ones: weighting, since treated UVs are larger and the same places move the rate less; and the denominator, which includes four-year-olds, who are mostly enrolled already.
- *"Does this change how you read the labor results?"* → Yes: the effect on mothers is an intent-to-treat of access in the UV, and it will be diluted relative to the number of new places.

### Slide 20 — Fertility

Fertility: no effect yet. Treated and control UVs decline together, there's no jump at opening, and pre-trends are clean. It's a fairly precise zero: we can rule out large effects. We're still checking: next, I'll look at a cumulative outcome, whether a woman has had a child, which gives more variation than births in a single year.

But this is what we'd expect: having a child depends on many factors, and a nearby preschool might weigh little among them.

*If asked:*
- *"How precise?"* → The average effect is zero, with a 95% confidence interval of plus or minus 0.2 points on a base of 4.3 percent. That rules out effects larger than about five percent.
- *"Is that precise enough?"* → For the UV, yes. But given a small first stage, the effect we'd expect from the literature is around one percent, which is inside the interval. More power would require focusing on mothers with young children.

### Slide 21 — Formal employment

This is our main labor result. Formal employment means having any taxable income or social security contribution in the year.

Nothing happens at opening, but employment rises gradually, and from the fourth year on it's about one point higher, significant in every year from four to seven. On a base of 49 percent, that's about two percent.

Why gradual? Each year, our sample is mothers with a child under five. In the opening year, many of those children are already three or four, so they have little time to use the new preschool. From around year four, every mother in the sample has had the preschool available since her child was born. So exposure builds up over time, and so does the effect.

One caution: the pre-trends are not significant, but they rise slightly. And the pre and post years come from different cohorts. The next step is a balanced event study, with the same cohorts before and after the opening.

*If asked:*
- *"One point on a two-point first stage is huge."* → Taken literally, yes, but the populations differ: enrollment is measured on children, employment on mothers with a child under five. We don't scale it yet.
- *"Could the gradual pattern be something else?"* → Also possible: finding a formal job takes time, and the new preschool may fill up gradually. The exposure story fits the timing best, but we haven't tested it separately.

### Slide 22 — Earnings

Earnings, among mothers who work, follow the same gradual shape as employment, with clean pre-trends. They rise to about three percent from year four. The average over the first seven years is 2.3 percent, around ten to twenty thousand pesos a month. It's suggestive, but not significant yet.

There are two things still to do. First, this is measured only among mothers with earnings, so new entrants, who probably earn less, may pull the average down. We'll add earnings in levels, including zeros for mothers without earnings; the log graph stays as it is, and this would be an additional one. Second, months worked: no effect so far, but it's also conditional on working. We'll re-estimate it with zero for mothers who don't work.

*If asked:*
- *"Why not just use levels with zeros?"* → We'll have both: the log tells us about earnings among those who work, and levels with zeros give the total effect, including mothers who start working.

### Slide 23 — By age of youngest child

By age of the youngest child, the employment effect shows up for mothers whose youngest is zero to three: about one to two points. When the youngest is four, there's no effect.

That fits the mechanism: mothers of younger children face a tighter care constraint. By age four, most children are already enrolled, 68 percent in the control group, so a new preschool changes less for those mothers. Each coefficient alone is not significant: the pattern across groups is what's informative.

So the employment effect comes from mothers of children aged zero to three, who need care the most.

*If asked:*
- *"Is this weighted?"* → No, this one is unweighted; the weighted version is not estimated yet.

### Slide 24 — Next steps

To close. Right away: first, the 2015 cohort — review the coverage data from JUNJI and Integra, and re-estimate everything without it. Second, complete the labor and fertility outcomes: earnings in levels including zeros, months worked including zeros, and a cumulative fertility outcome. In the short term, a balanced event study for employment, and aligning age definitions across datasets. In the medium term: mechanisms, using the RSH self-reports in the appendix; who fills the new preschool, using child-level enrollment; and writing up the results.

Thank you — happy to hear your comments.

---

## Appendix — quick reference if asked

- **A1, identification assumptions**: parallel trends, no anticipation, exogenous timing; placebo with pre-treatment birth rate.
- **A2, 2014–2015 UV data**: FPS has no reliable UV field; anchored to the 2016 UV.
- **A3, task status**: updated.
- **A4, balance in the fertility sample**: same conclusion, women alike, UVs differ in size.
- **A6, first-stage averages**: see the section below.
- **A8, childcare constraint graph**: event study of the "no one to leave the children with" outcome, with caveats: only mothers who neither work nor look for work answer the reason (others coded 0), the RSH form is not updated every year, and some UVs have very few answers.
- **A7, RSH self-reports (exploratory)**: fewer mothers say they don't look for work because they have no one to care for their children: −0.7pp unweighted (significant, clean pre-trends), −0.4pp weighted (same direction, weaker). Looking for work and hours: no effect. Household chores: not interpretable (pre-trends). Caveat: the RSH form isn't updated every year, and families may update it when applying for a preschool.
- **A5, months worked**: about +0.03 months on 8.7 (weighted), clean pre-trends. Conditional on working; to be re-estimated with 0 for mothers without work.

---

### Appendix A6 — First-stage average effect (linked from slide 14; open only if asked)

Here are the averages. Our main number is the weighted one: averaging the first seven years, enrollment rises by 1.9 points on a base of 33 percent, about six percent. Before the opening, the weighted average is essentially zero. Unweighted, it's 3.1 points, with a joint pre-test p-value of 0.9.

This is clearer than what I showed last time. Before, the model didn't include all the event-time dummies, and the negative coefficient at minus two came from TWFE. With Sun-Abraham, it disappears.

*If asked:*
- *"Where is the weighted standard error?"* → Pending: we didn't save the covariance matrix for the weighted model in this extraction. Every weighted coefficient from k = 0 to 6 is individually significant.
- *"Why use the covariance matrix for the SE?"* → The coefficients share the same reference year and control group, so they're correlated. Ignoring that gives a standard error less than half as large.

---

## To check before the meeting

- **Numbers without the 2015 cohort** (slide 16) were read from the RIS screen. Confirm with the V matrix before presenting them as more than preliminary.
- **Employment average with SE**: confirm the weighted average with `lincom` directly in the RIS (0.59pp, SE 0.28).
- **UV counts**: design 447 / 4,145 (slide 6), estimation 422 / 4,146 (slides 16, 18), balance 422 / 3,909. Have a one-line answer ready on why UVs drop out.
- **Median area** on slide 18 uses the design sample (4,175 / 2,163 / 647), not the estimation sample.
