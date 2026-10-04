import os
import base64

screenshot_dir = "/Users/sahilpandey/Desktop/prangan/assets/screenshots"

screenshots = [
    ("01_splash.png", "Figure 4.1: Splash Screen", "Displays the custom Sanskrit Prāngan crest emblem with smooth fade animation while verifying active Firebase session credentials."),
    ("02_welcome.png", "Figure 4.2: Welcome & Sign-In Screen", "Provides Google OAuth 2.0 single sign-on and Email/Password registration forms with client-side regex input validation."),
    ("03_join_society.png", "Figure 4.3: Join Society Selection Screen", "Enables incoming residents to search and select their respective residential complex or campus from live Firestore records."),
    ("04_confirm_details.png", "Figure 4.4: Confirm Resident Details Screen", "Collects essential resident profile attributes including Wing, Apartment/Flat Number, and resident tenure status."),
    ("05_pending_approval.png", "Figure 4.5: Pending Admin Approval Screen", "Real-time holding interface listening to Firestore snapshot streams; auto-unlocks to the Dashboard when approved by committee."),
    ("06_dashboard.png", "Figure 4.6: Society Dashboard Screen", "The primary landing hub featuring society metadata, active high-contrast SOS emergency alert banners, quick action shortcuts, and upcoming events."),
    ("07_discussions.png", "Figure 4.7: Community Discussion Forum Feed", "Scrollable feed of community issues, photo attachments, real-time like toggles, and engagement telemetry."),
    ("08_new_post.png", "Figure 4.8: Create New Post Screen", "Allows residents to compose community issues and attach photos directly from the mobile camera or gallery via image_picker."),
    ("09_post_detail.png", "Figure 4.9: Post Detail & Threaded Comments Screen", "Presents high-resolution post attachments and threaded real-time resident comments with author timestamps."),
    ("10_events.png", "Figure 4.10: Community Events Calendar Screen", "Displays scheduled society gatherings, Annual General Meetings (AGM), and festival celebrations with formatted dates."),
    ("11_polls.png", "Figure 4.11: Live Community Polls Screen", "Democratic decision-making interface featuring real-time animated horizontal progress bars showing vote percentages."),
    ("12_create_poll.png", "Figure 4.12: Create Community Poll Screen", "Administrative tool enabling committee members to propose questions and configure multi-choice voting options."),
    ("13_alerts.png", "Figure 4.13: Society Notices & Alerts Screen", "Chronological archive of all administrative advisories, maintenance schedules, and water/power outage notices."),
    ("14_sos_broadcast.png", "Figure 4.14: Emergency SOS Broadcast Screen", "High-priority alert dispatch console for security personnel to broadcast instantaneous crisis warnings to all resident devices."),
    ("15_admin_approvals.png", "Figure 4.15: Admin Member Approvals Panel", "Role-gated management console displaying pending resident verification requests with single-tap Approve and Reject actions.")
]

screen_cards = []
for img_name, fig_title, fig_desc in screenshots:
    img_path = os.path.join(screenshot_dir, img_name)
    if os.path.exists(img_path):
        with open(img_path, "rb") as f:
            b64_data = base64.b64encode(f.read()).decode("utf-8")
        src = f"data:image/png;base64,{b64_data}"
    else:
        src = ""
    
    card = f"""
    <div class="screen-card">
        <div class="img-wrapper">
            <img src="{src}" alt="{fig_title}" />
        </div>
        <div class="caption">
            <strong>{fig_title}</strong>
            <p>{fig_desc}</p>
        </div>
    </div>"""
    screen_cards.append(card)

screen_html = "\n".join(screen_cards)

template = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PRĀNGAN - Academic Project Report - Sahil Pandey (150096724024)</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&family=Playfair+Display:ital,wght@0,600;0,700;1,400&family=JetBrains+Mono:wght@400;600&display=swap" rel="stylesheet">
    <style>
        @page {
            size: A4;
            margin: 20mm;
        }
        body {
            font-family: 'Outfit', sans-serif;
            color: #2D3748;
            background-color: #FAF7F2;
            line-height: 1.7;
            margin: 0;
            padding: 40px 20px;
        }
        .container {
            max-width: 900px;
            margin: 0 auto;
            background: #FFFFFF;
            padding: 60px 80px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.08);
            border-radius: 8px;
        }
        @media print {
            body {
                background: #FFF;
                padding: 0;
            }
            .container {
                box-shadow: none;
                padding: 0;
                max-width: 100%;
            }
            .page-break {
                page-break-after: always;
            }
        }
        h1, h2, h3, h4 {
            color: #86243A;
            font-family: 'Outfit', sans-serif;
            font-weight: 700;
        }
        .cover-page {
            text-align: center;
            padding: 60px 0;
        }
        .cover-badge {
            display: inline-block;
            background: #DAB15C;
            color: #5B1625;
            padding: 6px 18px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 700;
            letter-spacing: 1.5px;
            margin-bottom: 25px;
            text-transform: uppercase;
        }
        .main-title {
            font-family: 'Playfair Display', serif;
            font-size: 46px;
            color: #86243A;
            margin: 10px 0;
            letter-spacing: 1px;
        }
        .subtitle {
            font-size: 18px;
            color: #718096;
            margin-bottom: 40px;
            font-style: italic;
        }
        .meta-box {
            background: #FAF7F2;
            border-top: 3px solid #86243A;
            border-bottom: 3px solid #86243A;
            padding: 30px;
            margin: 40px 0;
            border-radius: 4px;
        }
        .author-name {
            font-size: 26px;
            font-weight: 800;
            color: #86243A;
            margin: 5px 0;
        }
        .roll-no {
            font-size: 18px;
            color: #4A5568;
            font-weight: 600;
        }
        .dept {
            font-size: 15px;
            color: #718096;
            margin-top: 15px;
        }
        .section-title {
            border-bottom: 2px solid #86243A;
            padding-bottom: 8px;
            margin-top: 45px;
            margin-bottom: 20px;
            font-size: 24px;
        }
        .signatures {
            display: flex;
            justify-content: space-between;
            margin-top: 60px;
            text-align: center;
        }
        .sig-block {
            width: 45%;
            border-top: 1px solid #CBD5E0;
            padding-top: 10px;
            font-weight: 600;
            color: #4A5568;
            font-size: 14px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 25px 0;
            font-size: 14px;
        }
        th, td {
            border: 1px solid #E2E8F0;
            padding: 12px 14px;
            text-align: left;
        }
        th {
            background-color: #86243A;
            color: #FFFFFF;
            font-weight: 600;
        }
        tr:nth-child(even) {
            background-color: #FAF7F2;
        }
        .screens-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 25px;
            margin: 30px 0;
        }
        .screen-card {
            background: #FAF7F2;
            border: 1px solid #E2E8F0;
            border-radius: 12px;
            padding: 15px;
            text-align: center;
            box-shadow: 0 4px 10px rgba(0,0,0,0.04);
        }
        .screen-card img {
            width: 100%;
            border-radius: 8px;
            border: 1px solid #CBD5E0;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        .screen-card .caption {
            margin-top: 12px;
            text-align: left;
        }
        .screen-card .caption strong {
            color: #86243A;
            font-size: 14px;
            display: block;
            margin-bottom: 4px;
        }
        .screen-card .caption p {
            margin: 0;
            font-size: 12px;
            color: #4A5568;
            line-height: 1.4;
        }
        .badge-pass {
            background: #38A169;
            color: white;
            padding: 3px 8px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: bold;
        }
    </style>
</head>
<body>
<div class="container">

    <!-- COVER PAGE -->
    <div class="cover-page page-break">
        <div class="cover-badge">ACADEMIC MAJOR PROJECT REPORT</div>
        <div class="main-title">PRĀNGAN (प्रांगण)</div>
        <div class="subtitle">A Smart Cross-Platform Community Management & Governance Platform</div>
        
        <p style="margin: 40px 0 20px 0; font-size: 15px; color: #4A5568;">
            Submitted in partial fulfillment of the requirements for the award of the Degree of
        </p>
        <h3 style="color: #86243A; margin-bottom: 40px;">
            BACHELOR OF TECHNOLOGY / SCIENCE<br/>IN COMPUTER SCIENCE & ENGINEERING
        </h3>

        <div class="meta-box">
            <div style="font-size: 13px; text-transform: uppercase; letter-spacing: 1px; color: #718096;">Submitted By:</div>
            <div class="author-name">SAHIL PANDEY</div>
            <div class="roll-no">Roll No: 150096724024</div>
            <div class="dept">
                Department of Computer Engineering & Information Technology<br/>
                Academic Year: 2025 – 2026
            </div>
        </div>
    </div>

    <!-- DECLARATION -->
    <div class="page-break" style="padding-top: 30px;">
        <h2 class="section-title">CANDIDATE'S DECLARATION</h2>
        <p>
            I hereby declare that the project work entitled <strong>"PRĀNGAN — A Smart Cross-Platform Community Management & Governance Platform"</strong> 
            is an authentic record of my own work carried out under academic supervision.
        </p>
        <p>
            The matter embodied in this report has not been submitted by me or anyone else for the award of any other degree or diploma to any other University or Institute.
        </p>
        <br/><br/>
        <p>
            <strong>Date:</strong> October 4, 2026<br/>
            <strong>Place:</strong> Navi Mumbai, Maharashtra
        </p>
        <br/><br/>
        <div style="margin-top: 40px;">
            <strong>___________________________</strong><br/>
            <strong>SAHIL PANDEY</strong><br/>
            Roll No: <strong>150096724024</strong>
        </div>
    </div>

    <!-- CERTIFICATE -->
    <div class="page-break" style="padding-top: 30px;">
        <h2 class="section-title">CERTIFICATE OF APPROVAL</h2>
        <p>
            This is to certify that the project entitled <strong>"PRĀNGAN — A Smart Cross-Platform Community Management & Governance Platform"</strong>, 
            submitted by <strong>SAHIL PANDEY (Roll No: 150096724024)</strong>, has been successfully completed under proper guidance and satisfies all the 
            academic requirements for the major project submission for the Degree of Bachelor of Technology/Science in Computer Engineering.
        </p>
        <br/><br/><br/>
        <div class="signatures">
            <div class="sig-block">
                Project Guide / Supervisor<br/>Dept. of Computer Engineering
            </div>
            <div class="sig-block">
                Head of Department (HOD)<br/>Dept. of Computer Engineering
            </div>
        </div>
        <br/><br/><br/><br/>
        <div class="signatures">
            <div class="sig-block">
                Internal Examiner
            </div>
            <div class="sig-block">
                External Examiner
            </div>
        </div>
    </div>

    <!-- ABSTRACT -->
    <div class="page-break" style="padding-top: 30px;">
        <h2 class="section-title">ABSTRACT</h2>
        <p>
            Modern residential societies, university campuses, and gated communities face substantial operational challenges in maintaining seamless communication, governance, emergency broadcasts, and participatory decision-making. Conventional communication channels—principally disorganized WhatsApp groups and physical notice boards—suffer from information dilution, lack of role verification, security vulnerabilities, absence of democratic polling mechanisms, and sluggish crisis response times.
        </p>
        <p>
            To mitigate these systemic deficiencies, this project presents <strong>Prāngan (प्रांगण)</strong>, a robust, cross-platform community management and governance system built on Flutter, Dart, and Firebase Cloud Infrastructure. Prāngan establishes an end-to-end verified ecosystem using Role-Based Access Control (RBAC), multi-tenant society structures, and real-time synchronization mechanisms.
        </p>
        <p><strong>Key deliverables include:</strong></p>
        <ul>
            <li><strong>Automated Resident Onboarding & Admin Approvals:</strong> Ensuring only authenticated, verified occupants access community services.</li>
            <li><strong>Interactive Community Forum:</strong> Threaded discussions, multimedia attachments, and real-time like/comment telemetry.</li>
            <li><strong>Democratic Community Polling:</strong> Live single-choice voting with real-time dynamic tally animations.</li>
            <li><strong>Instant Emergency Broadcast (SOS):</strong> High-priority alerts broadcasted instantly to all resident dashboards with zero latency via Firestore WebSocket/gRPC streams.</li>
            <li><strong>Event Management:</strong> Comprehensive scheduling and RSVP system for community gatherings.</li>
        </ul>
        <p>
            Developed under the Model-View-ViewModel (MVVM) architectural pattern with the Provider state management paradigm, Prāngan guarantees clean separation of business logic, high responsiveness across diverse screen form-factors, and low network bandwidth overhead. Testing demonstrated sub-second data synchronization, zero state fragmentation, and complete security isolation.
        </p>
    </div>

    <!-- CHAPTER 1 -->
    <div>
        <h2 class="section-title">CHAPTER 1: INTRODUCTION</h2>
        <h3>1.1 Background & Motivation</h3>
        <p>
            Urbanization has precipitated the exponential growth of multi-story cooperative housing societies, gated residential complexes, and integrated university townships. In such dense communal environments, continuous interaction between residents, management committees, security personnel, and administrative bodies is paramount.
        </p>
        <p>
            Historically, community interaction relied upon physical gatherings, paper circulars pinned to notice boards, or telephone directories. While instant messaging platforms provided temporary convenience, they quickly evolved into hubs of spam, disorganized chatter, and misinformation. The motivation behind Prāngan stems from the urgent necessity for a dedicated, structured, secure, and democratic platform tailored specifically to the operational lifecycle of residential communities.
        </p>

        <h3>1.2 Problem Statement</h3>
        <ol>
            <li><strong>Unstructured Communication:</strong> Critical emergency notifications are treated with the same priority as casual chat.</li>
            <li><strong>Absence of Identity Verification:</strong> Open messaging channels permit unauthorized individuals or ex-tenants to monitor internal matters.</li>
            <li><strong>Inefficient Democratic Processes:</strong> Physical attendance at General Body Meetings (AGM) is consistently low.</li>
            <li><strong>Delayed Emergency Transmission:</strong> Security personnel lack an instantaneous, zero-latency panic broadcast mechanism.</li>
            <li><strong>Platform Inconsistency:</strong> Disparate operating systems (Android, iOS) lead to fragmented user experiences.</li>
        </ol>

        <h3>1.3 Objectives & Scope</h3>
        <ul>
            <li>To engineer a high-performance cross-platform mobile solution using Flutter and Dart.</li>
            <li>To implement Role-Based Access Control (RBAC) separating residents and administrators.</li>
            <li>To implement live community polling with animated percentage recalculations.</li>
            <li>To build a zero-delay SOS alerting engine flashing critical red banners across all active user devices.</li>
            <li>To enforce MVVM and Provider architectural standards for modular maintainability.</li>
        </ul>
    </div>

    <!-- CHAPTER 2 -->
    <div>
        <h2 class="section-title">CHAPTER 2: LITERATURE SURVEY & COMPARATIVE ANALYSIS</h2>
        <p>A rigorous review was conducted comparing Prāngan against contemporary market alternatives:</p>
        <table>
            <thead>
                <tr>
                    <th>Evaluation Metric</th>
                    <th>WhatsApp Groups</th>
                    <th>Commercial Gatekeepers</th>
                    <th>PRĀNGAN (Proposed)</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><strong>Identity Verification & RBAC</strong></td>
                    <td>None</td>
                    <td>Partial</td>
                    <td><strong style="color:#86243A;">Strict Admin Approval Workflow</strong></td>
                </tr>
                <tr>
                    <td><strong>SOS Emergency Broadcast</strong></td>
                    <td>Text only</td>
                    <td>Buried in menus</td>
                    <td><strong style="color:#86243A;">Prominent Instant Red Banner</strong></td>
                </tr>
                <tr>
                    <td><strong>Real-Time Live Polling</strong></td>
                    <td>Basic Poll</td>
                    <td>Paid add-on</td>
                    <td><strong style="color:#86243A;">Live Dynamic Animated Tallies</strong></td>
                </tr>
                <tr>
                    <td><strong>Grievance Tracking</strong></td>
                    <td>Unstructured</td>
                    <td>Proprietary</td>
                    <td><strong style="color:#86243A;">Integrated Discussion Forum</strong></td>
                </tr>
                <tr>
                    <td><strong>Data Privacy & Security</strong></td>
                    <td>Phone numbers exposed</td>
                    <td>Ad-tracking / monetized</td>
                    <td><strong style="color:#86243A;">Encrypted UID-Gated Data Model</strong></td>
                </tr>
                <tr>
                    <td><strong>Cross-Platform Support</strong></td>
                    <td>Native Apps</td>
                    <td>Native Apps</td>
                    <td><strong style="color:#86243A;">Flutter (Android, iOS, Web)</strong></td>
                </tr>
            </tbody>
        </table>
    </div>

    <!-- CHAPTER 3 -->
    <div>
        <h2 class="section-title">CHAPTER 3: SYSTEM ARCHITECTURE & DATABASE DESIGN</h2>
        <h3>3.1 MVVM Architectural Model</h3>
        <p>Prāngan enforces the Model-View-ViewModel design pattern partitioned into four robust layers:</p>
        <ul>
            <li><strong>View Layer (lib/screens/, lib/widgets/):</strong> Pure declarative UI components consuming data reactively.</li>
            <li><strong>ViewModel Layer (lib/providers/):</strong> Six dedicated ChangeNotifier state containers (AuthProvider, SocietyProvider, PostProvider, EventProvider, PollProvider, AlertProvider) that notify listening widgets.</li>
            <li><strong>Service Layer (lib/services/):</strong> Modular API classes handling direct communication with Firebase backend services.</li>
            <li><strong>Model Layer (lib/models/):</strong> Strongly-typed entities utilizing Dart 3 Sound Null Safety and factory constructors (fromFirestore, toMap).</li>
        </ul>

        <h3>3.2 Database Schema (Cloud Firestore)</h3>
        <ul>
            <li><code>users</code>: uid, name, email, photoUrl, role, status, societyId, wing, flatNumber</li>
            <li><code>societies</code>: societyId, name, description, location, adminUid, memberCount</li>
            <li><code>posts</code>: postId, authorId, authorName, societyId, content, imageUrl, likes array, commentCount</li>
            <li><code>polls</code>: pollId, question, societyId, options array, votes map (uid: optionIndex), createdAt</li>
            <li><code>alerts</code>: alertId, message, severity (info/warning/sos), societyId, createdBy, createdAt</li>
        </ul>
    </div>

    <!-- CHAPTER 4 (WITH ALL 15 SCREENSHOTS) -->
    <div class="page-break">
        <h2 class="section-title">CHAPTER 4: COMPLETE SCREEN WALKTHROUGH & VISUAL RESULTS</h2>
        <p>All fifteen core interfaces developed in the Prāngan application are presented below with operational overviews:</p>

        <div class="screens-grid">
            __SCREENS_PLACEHOLDER__
        </div>
    </div>

    <!-- CHAPTER 5 -->
    <div>
        <h2 class="section-title">CHAPTER 5: TESTING & PERFORMANCE EVALUATION</h2>
        <p>Formal functional and integration test cases executed on physical devices:</p>
        <table>
            <thead>
                <tr>
                    <th>Test ID</th>
                    <th>Test Objective</th>
                    <th>Expected Output</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><strong>TC-01</strong></td>
                    <td>Google OAuth 2.0 Sign-In</td>
                    <td>Token verified, Firestore user profile created</td>
                    <td><span class="badge-pass">PASS</span></td>
                </tr>
                <tr>
                    <td><strong>TC-02</strong></td>
                    <td>Email Form Regex Validation</td>
                    <td>Invalid email pattern rejected with error banner</td>
                    <td><span class="badge-pass">PASS</span></td>
                </tr>
                <tr>
                    <td><strong>TC-03</strong></td>
                    <td>Resident Society Affiliation</td>
                    <td>User doc tagged with societyId, status = pending</td>
                    <td><span class="badge-pass">PASS</span></td>
                </tr>
                <tr>
                    <td><strong>TC-04</strong></td>
                    <td>RBAC Access Gating</td>
                    <td>Pending user held on PendingApprovalScreen</td>
                    <td><span class="badge-pass">PASS</span></td>
                </tr>
                <tr>
                    <td><strong>TC-05</strong></td>
                    <td>Admin Approval Action</td>
                    <td>Status mutated to approved in Cloud Firestore</td>
                    <td><span class="badge-pass">PASS</span></td>
                </tr>
                <tr>
                    <td><strong>TC-06</strong></td>
                    <td>Real-Time Dashboard Unlock</td>
                    <td>Resident screen transitions to Dashboard in &lt;1s</td>
                    <td><span class="badge-pass">PASS</span></td>
                </tr>
                <tr>
                    <td><strong>TC-07</strong></td>
                    <td>Discussion Post Attachment</td>
                    <td>Image stored in Firebase Storage; doc created</td>
                    <td><span class="badge-pass">PASS</span></td>
                </tr>
                <tr>
                    <td><strong>TC-08</strong></td>
                    <td>Single Vote Enforcement</td>
                    <td>Second voting attempt prevented per UID</td>
                    <td><span class="badge-pass">PASS</span></td>
                </tr>
                <tr>
                    <td><strong>TC-09</strong></td>
                    <td>Dynamic Poll Recalculation</td>
                    <td>Vote percentage bars animate in real-time</td>
                    <td><span class="badge-pass">PASS</span></td>
                </tr>
                <tr>
                    <td><strong>TC-10</strong></td>
                    <td>Emergency SOS Alert Flash</td>
                    <td>Red SOS banner appears on all active client devices</td>
                    <td><span class="badge-pass">PASS</span></td>
                </tr>
            </tbody>
        </table>
    </div>

    <!-- CHAPTER 6 -->
    <div>
        <h2 class="section-title">CHAPTER 6: CONCLUSION & FUTURE SCOPE</h2>
        <p>
            The Prāngan application successfully proves how cross-platform mobile engineering can modernize residential and campus governance. By eliminating disorganized chat groups and establishing verified, real-time, and democratic channels, Prāngan delivers transparency and peace of mind to community living.
        </p>
        <p><strong>Planned Future Enhancements:</strong></p>
        <ol>
            <li><strong>Digital Maintenance Payments:</strong> UPI / QR-code payment gateway integration for automated billing and receipt generation.</li>
            <li><strong>Visitor Gatekeeper Passes:</strong> Resident-generated dynamic QR codes for visitor and delivery verification.</li>
            <li><strong>Gemini AI Grievance Categorization:</strong> Automated NLP classification and ticket routing for maintenance tasks.</li>
        </ol>
    </div>

    <br/><br/>
    <div style="text-align: center; border-top: 1px solid #E2E8F0; padding-top: 20px; color: #718096; font-size: 13px;">
        <strong>PRĀNGAN Academic Project Report</strong> · Prepared by <strong>Sahil Pandey</strong> (Roll No: <strong>150096724024</strong>) · October 2026
    </div>

</div>
</body>
</html>
"""

final_html = template.replace("__SCREENS_PLACEHOLDER__", screen_html)

desktop_html = "/Users/sahilpandey/Desktop/PRANGAN_PROJECT_REPORT.html"
with open(desktop_html, "w", encoding="utf-8") as f:
    f.write(final_html)

print(f"Successfully generated HTML report at: {desktop_html}")
