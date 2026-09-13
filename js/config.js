/* =========================================================
   SITE CONFIG — edit this file to re-skin the demo per prospect.
   Everything visible on the site (brand, colors, copy, nav groups,
   every sub-page, swatches, reviews, FAQ, stats) lives here.
   Routing is hash-based (#/services/roof-replacement) so the site
   works as static files with no server configuration.
   ========================================================= */
window.CONFIG = {
  brand: {
    name: "Northline",
    tagline: "Home Services",
    legalName: "Northline Home Services",
    phone: "1-800-555-0199",
    email: "hello@northlinehome.com",
    hours: ["Mon–Sat · 7am–9pm ET", "Sun · 9am–6pm ET"],
    address: ["1200 Ridgeline Dr, Suite 400", "Chester, PA 19013"],
    license: "PA HIC #000000",
    serviceArea: "Licensed & insured in PA, NJ, DE, MD and VA.",
    /* Accent color drives buttons, highlights, and the logo mark. */
    colors: { accent: "#e3122b", accentDark: "#b80d21" }
  },

  promo: {
    tag: "Limited time",
    text: "Save up to $2,500 on a full roof replacement + 0% APR for 18 months.",
    cta: "Claim offer"
  },

  hero: {
    eyebrow: "Roof Replacement & Repair",
    lines: ["A roof built to", "outlast <em>the weather.</em>"],
    sub: "Storm-rated architectural shingles, a fully engineered ventilation system, and installers who treat your home like their own. Backed by a lifetime workmanship warranty.",
    primary: "Schedule a Free Consultation",
    secondary: "See how it's built",
    trust: [
      "<span class=\"stars\" aria-label=\"4.9 out of 5 stars\">★★★★★</span> <strong>4.9</strong> from 18,400+ reviews",
      "<strong>Lifetime</strong> workmanship warranty",
      "<strong>$0 down</strong> financing available"
    ]
  },

  stats: [
    { v: 32, suffix: "<sup>+</sup>", label: "Years protecting homes" },
    { v: 1.2, dec: 1, suffix: "M", label: "Homes served nationwide" },
    { v: 98, suffix: "%", label: "Would recommend to a friend" },
    { v: 50, suffix: "<sup>yr</sup>", label: "Manufacturer material warranty" }
  ],

  marquee: ["Certified Master Installers", "Class 4 Impact Rated", "130 MPH Wind Warranty", "Energy Star Partner", "Fully Licensed & Insured", "A+ Better Business Rating"],

  why: {
    eyebrow: "Why homeowners choose Northline",
    head: "Engineered for the <em>worst day</em> of the year.",
    lede: "Most roofs fail at the details: the valleys, the vents, the flashing nobody sees. We over-build every one of them, so you never think about your roof again.",
    features: [
      { icon: "home", t: "Class 4 impact-rated shingles", d: "The highest hail and impact rating available, with a 130 mph wind warranty and algae-resistant granules that keep their color for decades." },
      { icon: "drop", t: "Ice & water barrier", d: "Self-sealing membrane in every valley, eave, and penetration, so wind-driven rain and ice dams never reach your decking." },
      { icon: "vent", t: "Balanced attic ventilation", d: "Ridge and intake vents sized to your exact attic volume, lowering summer cooling bills and stopping moisture before it rots the wood." },
      { icon: "shield", t: "Lifetime workmanship warranty", d: "If anything we installed ever leaks, we fix it. No pro-rating, no fine print, and it transfers to the next owner of your home." },
      { icon: "crew", t: "Employee installers, not subs", d: "Every crew is background-checked, factory-certified, and employed by us. One project manager owns your job from tear-off to final walk-through." },
      { icon: "calendar", t: "Done in a day", d: "Most homes are torn off, dried in, and fully installed in a single day, with magnetic nail sweeps and a spotless yard before we leave." }
    ]
  },

  system: {
    eyebrow: "The Northline Roofing System",
    head: "Seven layers. <em>Zero</em> weak points.",
    lede: "A roof is only as strong as what's under the shingles. Tap a layer to see what it does and why we never skip it.",
    /* Top of the roof first. Exactly seven entries map to the diagram. */
    layers: [
      { t: "Ridge vent", d: "Exhausts hot, humid attic air along the peak." },
      { t: "Architectural shingles", d: "Class 4 impact, 130 mph wind, 50-year material warranty." },
      { t: "Starter strip", d: "Factory-sealed edge locks the first course against uplift." },
      { t: "Synthetic underlayment", d: "Tear-resistant, breathable secondary water barrier." },
      { t: "Ice & water shield", d: "Self-adhering membrane at eaves, valleys and penetrations." },
      { t: "Drip edge & flashing", d: "Heavy-gauge metal that steers water into the gutters." },
      { t: "Inspected decking", d: "Every sheet checked and replaced if soft, at no surprise cost." }
    ]
  },

  colors: {
    eyebrow: "Design your roof",
    head: "Pick a color. <em>See it</em> on your home.",
    lede: "Twelve designer shades, all with the same Class 4 protection. Choose one below and watch the house update in real time.",
    swatches: [
      { n: "Charcoal Slate", base: "#3a3f4a", line: "#14161b", hi: "#4a505c", tag: "Most popular" },
      { n: "Onyx Black", base: "#1d1f24", line: "#0a0b0d", hi: "#2b2e35" },
      { n: "Pewter Gray", base: "#6f747c", line: "#3a3e45", hi: "#868b93" },
      { n: "Weathered Wood", base: "#6b5a48", line: "#3a3026", hi: "#7f6d59" },
      { n: "Driftwood", base: "#8c8070", line: "#4e463c", hi: "#a2968a" },
      { n: "Hickory", base: "#5c4535", line: "#2f2219", hi: "#6e5544" },
      { n: "Mission Brown", base: "#4a3a2f", line: "#241b15", hi: "#5a4839" },
      { n: "Harbor Blue", base: "#3c4f66", line: "#1c2633", hi: "#4d6079" },
      { n: "Hunter Green", base: "#3b4e3f", line: "#1c261e", hi: "#4a5f4e" },
      { n: "Terra Cotta", base: "#9a5a3c", line: "#55301e", hi: "#ad6c4d" },
      { n: "Slate Blue", base: "#59677a", line: "#2c343f", hi: "#6b7a8e" },
      { n: "Birchwood", base: "#a89d8a", line: "#635b4d", hi: "#bcb2a0" }
    ],
    specs: [["Class 4", "Impact rating"], ["130 mph", "Wind warranty"], ["50 yr", "Material warranty"]],
    cta: "Get a quote in this color"
  },

  process: {
    eyebrow: "How it works",
    head: "From first call to <em>final sweep</em> in four steps.",
    steps: [
      { t: "Free in-home consultation", d: "A project specialist inspects your roof, attic and gutters with a drone and infrared scan, then walks you through exactly what we find.", time: "60–90 min" },
      { t: "Design & guaranteed price", d: "Choose your shingle color and options. Your price is locked in writing, with no change orders unless you change the scope.", time: "Same visit" },
      { t: "One-day installation", d: "Our employee crew protects your landscaping, tears off to the deck, replaces bad wood, and installs the full seven-layer system.", time: "1 day" },
      { t: "Inspection & lifetime care", d: "A project manager walks the roof with you, registers your warranties, and stays your single point of contact for life.", time: "Forever" }
    ]
  },

  beforeAfter: {
    eyebrow: "Real transformations",
    head: "Drag to see the <em>difference.</em>",
    caption: "Cedar Grove, MD · 28-year-old three-tab roof replaced with Charcoal Slate architectural shingles, new ridge vent, and seamless gutters. Completed in one day."
  },

  reviews: {
    eyebrow: "18,400+ five-star reviews",
    head: "Homeowners <em>say it best.</em>",
    items: [
      { t: "Crew showed up at 7, roof was done and yard spotless by 4. The project manager sent me drone photos of every stage. Never seen a contractor this organized.", name: "Dana M.", meta: "Roof replacement · Alexandria, VA", color: "#e3122b" },
      { t: "Two other companies quoted us without ever going in the attic. Northline found rotted decking the others missed and the price they wrote down was the price we paid.", name: "James & Priya R.", meta: "Roof & gutters · Cherry Hill, NJ", color: "#2f6bff" },
      { t: "Hail storm hit six months after install. Not a single mark. Our neighbors with the same storm are all getting new roofs right now.", name: "Tom K.", meta: "Roof replacement · Naperville, IL", color: "#1a9e5c" },
      { t: "The color visualizer was what sold my wife. Weathered Wood looks exactly like it did on the screen. Financing approval took about four minutes.", name: "Andre L.", meta: "Roof & solar · Tampa, FL", color: "#c26b1a" },
      { t: "Our attic went from 130° to 95° in August after they fixed the ventilation. Didn't know a roof could change our electric bill.", name: "Sarah W.", meta: "Roof replacement · Phoenix, AZ", color: "#7a3fe0" }
    ],
    ratings: [["4.9", "Google"], ["A+", "BBB Rating"], ["4.8", "Trustpilot"], ["#1", "Qualified Remodeler Top 500"]]
  },

  tracker: {
    eyebrow: "Track your project",
    head: "Know exactly where <em>your roof</em> stands.",
    lede: "Every job gets a private tracking page. No wondering when the crew shows up, no chasing paperwork.",
    list: ["Appointment reminders by text", "Daily photo updates from the roof", "Sign approvals from your phone", "Warranty documents stored for good"],
    progress: 52,
    steps: [
      { t: "Estimate approved", state: "done" },
      { t: "Materials delivered", state: "done" },
      { t: "Tear-off & install — today", state: "now" },
      { t: "Final walkthrough" },
      { t: "Warranty registered" }
    ]
  },

  financing: {
    eyebrow: "Financing that fits",
    head: "Protect your home for <em>less per month</em> than your streaming bills.",
    lede: "$0 down, 0% APR promotional plans, and approvals in minutes with no impact to your credit score to check. Every plan has no prepayment penalty.",
    list: ["0% APR for 18 months on approved credit", "Fixed-rate plans up to 15 years", "Instant soft-pull pre-qualification", "Insurance claim specialists on staff"],
    apr: 7.99,
    defaultAmount: 18500,
    defaultTerm: 10
  },

  services: {
    eyebrow: "Whole-home exterior",
    head: "One crew. <em>Every</em> exterior project."
  },

  faq: {
    eyebrow: "Questions, answered",
    head: "Everything you want to know <em>before</em> we knock.",
    lede: "Still curious? Call us and a real person will pick up.",
    groups: {
      "General": [
        ["How do I know if I need a new roof or just a repair?", "If your roof is over 18 years old, has curling or missing shingles, granules in the gutters, or any interior staining, a replacement is usually the better investment. Our free inspection includes a drone survey and infrared moisture scan, and we'll tell you honestly if a repair will hold."],
        ["How long does a new roof last?", "Architectural shingles with balanced ventilation typically last 30 years or more in a freeze-thaw climate. The 50-year material warranty covers the shingles themselves."],
        ["Can a new roof lower my insurance premium?", "Many carriers discount for Class 4 impact-rated shingles and a documented new install. We provide the certification paperwork for your agent."]
      ],
      "Process": [
        ["How long does a roof replacement take?", "Most single-family homes are completed in one day. Larger or steeper roofs may take two. You can stay home during the work, though it does get loud."],
        ["What happens if you find rotted wood?", "We inspect every sheet of decking after tear-off and replace anything soft. Your quote includes a decking allowance, and we photograph anything beyond it before we touch it so there are never surprises on the invoice."],
        ["Who actually does the work?", "Our own employed, factory-certified crews. The same lead installer stays on your job from tear-off to final walk-through."]
      ],
      "Financing & warranty": [
        ["What does the lifetime workmanship warranty cover?", "Any leak or failure caused by installation, for as long as you own the home, with no pro-rating. It's fully transferable to the next owner, which is a strong selling point when you list."],
        ["Is financing really 0% APR?", "Yes, on approved credit for the promotional term. There is no prepayment penalty, and pre-qualification is a soft pull that does not affect your credit score."],
        ["Do you work with insurance claims?", "Yes. Our claims specialists document storm damage, meet your adjuster on-site, and handle the supplement process so you pay only your deductible where a claim is approved."]
      ]
    }
  },

  quote: {
    eyebrow: "Free consultation",
    head: "Let's take a look at <em>your roof.</em>",
    lede: "Tell us a little about your home and a project specialist will call within 15 minutes during business hours to set up your free inspection.",
    list: ["No-pressure, no-obligation visit", "Drone & infrared inspection included", "Written, guaranteed price on the spot"],
    services: ["Roofing", "Windows", "Siding", "Doors", "Solar", "Gutters"],
    fine: "By submitting, you agree to be contacted by Northline about your project. No spam, ever. This is a demo form; nothing is sent."
  },

  awards: ["4.9★ on Google", "A+ BBB Rating", "GAF Master Elite", "Angi Super Service", "Energy Star Partner"],
  topSearches: ["Free quote", "Roof replacement", "Warranty", "Financing", "Track my project", "Storm damage"],

  /* ---------------------------------------------------------------
     NAV GROUPS → each group gets a landing page (#/services) and each
     item gets its own page (#/services/roof-replacement).
     `home: true` items also appear in the home-page services grid.
     --------------------------------------------------------------- */
  nav: [
    { label: "Services", slug: "services", wide: true, lede: "Everything on the outside of your house, from one crew that answers the phone.", items: [
      { t: "Roofing", s: "roofing", d: "Full replacement & storm repair", icon: "home", tint: "#e3122b", home: true,
        body: ["A replacement starts with a full tear-off. We never lay new shingles over old ones. Once the deck is exposed we inspect every sheet, replace anything soft, then build the seven-layer system back up: ice-and-water shield, synthetic underlayment, starter strip, Class 4 architectural shingles, and ridge ventilation.", "Most homes are finished in a single day. You'll get a text when we start, drone photos through the day, and a walkthrough with your project manager before we leave."],
        hl: [["Full tear-off", "No layering over old shingles, ever."], ["Deck inspection", "Soft plywood replaced before anything goes on."], ["One-day install", "Most homes done start to finish in a day."]] },
      { t: "Roof repair", s: "roof-repair", d: "Leaks, flashing, storm blow-offs", icon: "tools", tint: "#f26b3a",
        body: ["Not every roof needs replacing. If the damage is isolated and the shingles have life left, a repair is the honest answer, and we'll tell you so. We handle missing shingles, failed pipe boots, chimney and skylight flashing, and storm blow-offs.", "Every repair comes with a two-year workmanship warranty and photos of exactly what we fixed."],
        hl: [["Same-week service", "Repairs scheduled within the week."], ["Photo documentation", "Before and after, sent to your phone."], ["Honest assessments", "If it's a repair, we say so."]] },
      { t: "Windows", s: "windows", d: "Energy-efficient replacement", icon: "window", tint: "#2f6bff", home: true,
        body: ["Custom-measured triple-pane windows with foam-filled frames, installed by the same employee crews that do our roofs. Every unit is wrapped, flashed and insulated so the wall around it performs as well as the glass.", "Expect quieter rooms, no drafts, and a visible drop in heating and cooling bills. Glass breakage is covered for life."],
        hl: [["Triple-pane glass", "Argon-filled with low-E coatings."], ["Custom fit", "Measured to the sixteenth of an inch."], ["Lifetime glass warranty", "Breakage included, no questions."]] },
      { t: "Siding", s: "siding", d: "Fiber cement & insulated vinyl", icon: "siding", tint: "#c26b1a", home: true,
        body: ["Insulated vinyl and fiber-cement siding installed over fresh house wrap with new flashing at every window and door. We often pair it with a roof so the whole exterior is finished at once.", "You'll see real samples on your actual house in daylight, not on a screen."],
        hl: [["Insulated vinyl", "Warmer walls and a quieter house."], ["Fiber cement", "Looks like wood, lasts like stone."], ["Bundle savings", "Roof plus siding scheduled together."]] },
      { t: "Doors", s: "doors", d: "Entry, patio & storm", icon: "door", tint: "#1a9e5c", home: true,
        body: ["Fiberglass and steel entry doors, sliding and French patio doors, and storm doors, all pre-hung in composite frames that never rot. Multi-point locks and adjustable thresholds come standard.", "Installed in a morning, with the old door hauled away."],
        hl: [["Composite frames", "Never rot, never swell."], ["Multi-point locks", "Secure at three points, not one."], ["Half-day install", "In and out before lunch."]] },
      { t: "Solar", s: "solar", d: "Roof-integrated systems", icon: "solar", tint: "#f2b01e", home: true,
        body: ["Solar designed and installed with the roof underneath it, by the same company, under one warranty. No finger-pointing between a roofer and a solar installer when something needs attention.", "We size the system to your actual usage, handle permitting and utility interconnection, and register every incentive you qualify for."],
        hl: [["One warranty", "Roof and panels covered together."], ["Right-sized", "Designed from your real usage data."], ["Incentives handled", "Federal, state and utility paperwork done."]] },
      { t: "Gutters", s: "gutters", d: "Seamless aluminum & guards", icon: "gutter", tint: "#7a3fe0", home: true,
        body: ["Seamless aluminum gutters rolled on site to fit your house exactly, in 20 colors. Add leaf guards and you stop climbing ladders every fall.", "We oversize downspouts for heavy downpours and pitch every run so nothing stands in the trough."],
        hl: [["Seamless", "Rolled on site, no joints to leak."], ["20 colors", "Matched to your trim or fascia."], ["Guards available", "Never clean gutters again."]] },
      { t: "Storm & insurance", s: "storm", d: "We meet the adjuster on site", icon: "wind", tint: "#5a8dee",
        body: ["After hail or wind, we inspect for free and document everything. If there's a claim, we meet your adjuster on the roof, walk them through the damage, and handle the supplement paperwork.", "You pay your deductible. We handle the rest."],
        hl: [["Free inspection", "Documented with photos and a report."], ["Adjuster meeting", "We're there so nothing gets missed."], ["Emergency tarping", "24-hour line for active leaks."]] }
    ]},
    { label: "Why Northline", slug: "about", lede: "Thirty-two years, 1.2 million homes, and still one project manager per job.", items: [
      { t: "Our story", s: "our-story", d: "Family-founded in 1994", icon: "flag",
        body: ["Northline started with one truck and a lot of tear-offs outside Philadelphia. Thirty-two years and 1.2 million homes later, we're still run by the same family, and our leadership still walks job sites every week.", "Nothing about the way we work is complicated: show up, do it right, put it in writing."],
        hl: [["1994", "One truck, one crew."], ["1.2M homes", "Across the Mid-Atlantic and beyond."], ["Still family-run", "Same owners, same standards."]] },
      { t: "Our crews", s: "our-crews", d: "Employed, not day labor", icon: "crew",
        body: ["Every installer is a Northline employee, trained, insured, and background-checked. No subcontractors and no rotating faces. The lead on your job has been with us at least five years.", "That's why we can stand behind a lifetime workmanship warranty."],
        hl: [["W-2 employees", "Not subs, not day labor."], ["Factory certified", "Manufacturer-trained installers."], ["Same lead all job", "One person who knows your roof."]] },
      { t: "Community", s: "community", d: "Roofs for Neighbors program", icon: "heart",
        body: ["Each year we replace roofs at no cost for families in need, nominated by their neighbors. We sponsor youth sports in every market we serve and show up first for storm cleanups.", "We live here. It's not marketing."],
        hl: [["Free roofs yearly", "Nominated by the community."], ["Youth sports", "Local team sponsorships."], ["Storm response", "Tarping for neighbors first."]] },
      { t: "Reviews", s: "reviews", d: "18,400+ homeowners", icon: "star",
        body: ["A 4.9-star average across 18,400 reviews, plus references on request. Read what neighbors say, then ask to see the work in person.", "We'll give you addresses of recent jobs so you can drive by."],
        hl: [["4.9 stars", "Across 18,400+ reviews."], ["References", "Real homeowners, real phone numbers."], ["Drive-by list", "See our work before you buy."]] }
    ]},
    { label: "Careers", slug: "careers", lede: "Year-round work with a crew that trains from the ground up.", items: [
      { t: "Open positions", s: "open-positions", d: "Installers, specialists, office", icon: "briefcase",
        body: ["We're hiring installers, project specialists, and office coordinators in every market. Competitive pay, health insurance, 401(k) match, and year-round work. Winter is windows, doors and interior prep, not layoffs.", "Send a note through the quote form and choose Careers, or call and ask for the office."],
        hl: [["Installers", "Experienced or apprentice."], ["Specialists", "In-home consultations and design."], ["Office", "Scheduling and customer care."]] },
      { t: "Apprenticeship", s: "apprenticeship", d: "Paid training, no experience needed", icon: "tools",
        body: ["Our 12-week paid apprenticeship takes you from never having held a nail gun to working on a crew. You're paid from day one and factory-certified at the end.", "Most of our lead installers started here."],
        hl: [["Paid from day one", "No unpaid training."], ["12 weeks", "Structured, on real jobs."], ["Certification", "Manufacturer credential at completion."]] },
      { t: "Benefits", s: "benefits", d: "Health, 401k, year-round work", icon: "shield",
        body: ["Health, dental, and vision. 401(k) with company match. Paid time off, paid holidays, and year-round work so you're not scrambling every December.", "Tools and safety gear provided. Company trucks for leads."],
        hl: [["Health & dental", "Company contributes."], ["401(k) match", "Retirement that actually grows."], ["Year-round", "No seasonal layoffs."]] }
    ]},
    { label: "Support", slug: "support", lede: "Already a customer? Everything you need is here.", items: [
      { t: "Track your project", s: "track-your-project", d: "Live status, photos, paperwork", icon: "phone",
        body: ["Every job gets a private tracking page. See your next appointment, daily photos from the crew, and every document in one place. Sign approvals from your phone.", "Your link is texted to you the day you approve the estimate."],
        hl: [["Live status", "Know what's happening today."], ["Daily photos", "Straight from the roof."], ["E-sign", "Approvals without printing."]] },
      { t: "Warranties", s: "warranties", d: "What's covered and how to claim", icon: "shield",
        body: ["Two warranties come with every Northline roof: the manufacturer's 50-year material warranty and our own lifetime workmanship warranty. Both are registered for you and stored on your project page.", "To make a claim, call or text. We schedule a visit within the week."],
        hl: [["Material", "50 years, manufacturer-backed."], ["Workmanship", "Lifetime, fully transferable."], ["Fast claims", "Visit scheduled within a week."]] },
      { t: "Financing", s: "financing", d: "0% for 18 months, on approved credit", icon: "calendar",
        body: ["0% APR for 18 months on approved credit, with fixed-rate terms available up to 15 years. Apply in five minutes with your project specialist. There is no hard credit pull until you choose a plan.", "No prepayment penalty on any plan."],
        hl: [["0% for 18 months", "On approved credit."], ["Up to 15 years", "Lower monthly options."], ["No penalty", "Pay off early anytime."]] },
      { t: "Licenses & insurance", s: "licenses-and-insurance", d: "License and coverage documents", icon: "doc",
        body: ["Licensed in every state we serve, with general liability and workers' compensation coverage on every job. Certificates are attached to every estimate and available on request.", "Ask any contractor for these before you sign. If they hesitate, walk."],
        hl: [["State licensed", "Number on every estimate."], ["$5M liability", "Certificate on request."], ["Workers' comp", "You're never on the hook."]] },
      { t: "Emergency tarping", s: "emergency", d: "24-hour storm line", icon: "wind",
        body: ["If your roof is actively leaking after a storm, call the 24-hour line. We'll tarp it the same day to stop the water, then schedule a full inspection.", "Tarping is free if we do the repair."],
        hl: [["24-hour line", "Same-day response."], ["Free with repair", "Tarp cost credited back."], ["Photos for insurance", "Documented from the start."]] }
    ]}
  ]
};
