import os
import docx
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml import OxmlElement, parse_xml
from docx.oxml.ns import nsdecls, qn

doc = Document()

# Set standard 1-inch margins
for section in doc.sections:
    section.top_margin = Inches(1)
    section.bottom_margin = Inches(1)
    section.left_margin = Inches(1)
    section.right_margin = Inches(1)

# Helper for cell shading
def set_cell_background(cell, fill_hex):
    tcPr = cell._tc.get_or_add_tcPr()
    shd = parse_xml(f'<w:shd {nsdecls("w")} w:fill="{fill_hex}"/>')
    tcPr.append(shd)

def set_cell_margins(cell, top=100, bottom=100, left=150, right=150):
    tcPr = cell._tc.get_or_add_tcPr()
    tcMar = parse_xml(f'<w:tcMar {nsdecls("w")}><w:top w:w="{top}" w:type="dxa"/><w:bottom w:w="{bottom}" w:type="dxa"/><w:left w:w="{left}" w:type="dxa"/><w:right w:w="{right}" w:type="dxa"/></w:tcMar>')
    tcPr.append(tcMar)

crimson = RGBColor(134, 36, 58)    # #86243A
gold = RGBColor(218, 177, 92)      # #DAB15C
dark_gray = RGBColor(50, 50, 50)

# ================= COVER PAGE =================
p = doc.add_paragraph()
p.alignment = WD_ALIGN_PARAGRAPH.CENTER
run = p.add_run("ACADEMIC PROJECT REPORT\n\n")
run.font.size = Pt(14)
run.font.bold = True
run.font.color.rgb = gold

p_title = doc.add_paragraph()
p_title.alignment = WD_ALIGN_PARAGRAPH.CENTER
run_title = p_title.add_run("PRĀNGAN (प्रांगण)\n")
run_title.font.size = Pt(28)
run_title.font.bold = True
run_title.font.color.rgb = crimson

run_sub = p_title.add_run("A Smart Cross-Platform Community Management & Governance Platform\n\n")
run_sub.font.size = Pt(15)
run_sub.font.italic = True
run_sub.font.color.rgb = dark_gray

p_body = doc.add_paragraph()
p_body.alignment = WD_ALIGN_PARAGRAPH.CENTER
r = p_body.add_run("A Major Project Report submitted in partial fulfillment of the requirements\nfor the award of the Degree of\n\n")
r.font.size = Pt(11)

r_deg = p_body.add_run("BACHELOR OF TECHNOLOGY / SCIENCE\nIN COMPUTER SCIENCE & ENGINEERING\n\n\n")
r_deg.font.size = Pt(13)
r_deg.font.bold = True
r_deg.font.color.rgb = crimson

r_sub = p_body.add_run("Submitted By:\n")
r_sub.font.size = Pt(12)

r_name = p_body.add_run("SAHIL PANDEY\n")
r_name.font.size = Pt(18)
r_name.font.bold = True
r_name.font.color.rgb = crimson

r_roll = p_body.add_run("Roll No: 150096724024\n\n\n")
r_roll.font.size = Pt(14)
r_roll.font.bold = True

r_dept = p_body.add_run("Department of Computer Engineering & Information Technology\nAcademic Year: 2025 – 2026\n")
r_dept.font.size = Pt(12)

doc.add_page_break()

# ================= DECLARATION =================
h1 = doc.add_heading("CANDIDATE'S DECLARATION", level=1)
h1.runs[0].font.color.rgb = crimson

p = doc.add_paragraph()
p.add_run(
    "I hereby declare that the project work entitled \"PRĀNGAN — A Smart Cross-Platform Community Management & Governance Platform\" "
    "is an authentic record of my own work carried out under academic supervision.\n\n"
    "The matter embodied in this report has not been submitted by me or anyone else for the award of any other degree or diploma to any other University or Institute.\n\n\n"
)

p_sig = doc.add_paragraph()
p_sig.add_run("Date: October 4, 2026\nPlace: Navi Mumbai, Maharashtra\n\n\n\n")
run_sig = p_sig.add_run("___________________________\nSAHIL PANDEY\nRoll No: 150096724024")
run_sig.font.bold = True

doc.add_page_break()

# ================= CERTIFICATE =================
h1 = doc.add_heading("CERTIFICATE OF APPROVAL", level=1)
h1.runs[0].font.color.rgb = crimson

p = doc.add_paragraph()
p.add_run(
    "This is to certify that the project entitled \"PRĀNGAN — A Smart Cross-Platform Community Management & Governance Platform\", "
    "submitted by SAHIL PANDEY (Roll No: 150096724024), has been successfully completed under proper guidance and satisfies all the "
    "academic requirements for the major project submission for the Degree of Bachelor of Technology/Science in Computer Engineering.\n\n\n\n"
)

table = doc.add_table(rows=2, cols=2)
table.alignment = WD_TABLE_ALIGNMENT.CENTER
table.rows[0].cells[0].paragraphs[0].add_run("___________________________\nProject Guide / Supervisor\nDept. of Computer Engineering").font.bold = True
table.rows[0].cells[1].paragraphs[0].add_run("___________________________\nHead of Department (HOD)\nDept. of Computer Engineering").font.bold = True
table.rows[1].cells[0].paragraphs[0].add_run("\n\n___________________________\nInternal Examiner").font.bold = True
table.rows[1].cells[1].paragraphs[0].add_run("\n\n___________________________\nExternal Examiner").font.bold = True

doc.add_page_break()

# ================= ABSTRACT =================
h1 = doc.add_heading("ABSTRACT", level=1)
h1.runs[0].font.color.rgb = crimson

p = doc.add_paragraph()
p.add_run(
    "Modern residential societies, university campuses, and gated communities face substantial operational challenges in maintaining seamless communication, governance, emergency broadcasts, and participatory decision-making. Conventional communication channels—principally disorganized WhatsApp groups and physical notice boards—suffer from information dilution, lack of role verification, security vulnerabilities, absence of democratic polling mechanisms, and sluggish crisis response times.\n\n"
    "To mitigate these systemic deficiencies, this project presents Prāngan (प्रांगण), a robust, cross-platform community management and governance system built on Flutter, Dart, and Firebase Cloud Infrastructure. Prāngan establishes an end-to-end verified ecosystem using Role-Based Access Control (RBAC), multi-tenant society structures, and real-time synchronization mechanisms.\n\n"
    "Key deliverables include:\n"
    "• Automated Resident Onboarding & Admin Approvals: Ensuring only authenticated, verified occupants access community services.\n"
    "• Interactive Community Forum: Threaded discussions, multimedia attachments, and real-time like/comment telemetry.\n"
    "• Democratic Community Polling: Live single-choice voting with real-time dynamic tally animations.\n"
    "• Instant Emergency Broadcast (SOS): High-priority alerts broadcasted instantly to all resident dashboards with zero latency via Firestore WebSocket/gRPC streams.\n"
    "• Event Management: Comprehensive scheduling and RSVP system for community gatherings.\n\n"
    "Developed under the Model-View-ViewModel (MVVM) architectural pattern with the Provider state management paradigm, Prāngan guarantees clean separation of business logic, high responsiveness across diverse screen form-factors, and low network bandwidth overhead. Testing demonstrated sub-second data synchronization, zero state fragmentation, and complete security isolation."
)

doc.add_page_break()

# Helper for adding sections
def add_chapter(title):
    h = doc.add_heading(title, level=1)
    h.runs[0].font.color.rgb = crimson
    return h

def add_section(title):
    h = doc.add_heading(title, level=2)
    h.runs[0].font.color.rgb = RGBColor(91, 22, 37)
    return h

# ================= CHAPTER 1 =================
add_chapter("CHAPTER 1: INTRODUCTION")
add_section("1.1 Background & Motivation")
doc.add_paragraph(
    "Urbanization has precipitated the exponential growth of multi-story cooperative housing societies, gated residential complexes, and integrated university townships. In such dense communal environments, continuous interaction between residents, management committees, security personnel, and administrative bodies is paramount.\n\n"
    "Historically, community interaction relied upon physical gatherings, paper circulars pinned to notice boards, or telephone directories. While the advent of mobile instant messaging platforms (such as WhatsApp, Telegram, and Facebook Groups) provided temporary convenience, they quickly evolved into hubs of spam, disorganized chatter, privacy infringements, and misinformation. Critical announcements such as emergency water shutoffs, fire drills, security breaches, or society election voting are frequently lost amidst hundreds of conversational messages.\n\n"
    "The motivation behind Prāngan stems from the urgent necessity for a dedicated, structured, secure, and democratic platform tailored specifically to the operational lifecycle of residential and campus communities."
)

add_section("1.2 Problem Statement")
doc.add_paragraph(
    "Existing community communication paradigms suffer from the following fundamental flaws:\n"
    "1. Unstructured Communication: Critical emergency notifications are treated with the same priority as casual chit-chat.\n"
    "2. Absence of Identity Verification: Open messaging channels permit unauthorized individuals or ex-tenants to monitor internal society matters.\n"
    "3. Inefficient Democratic Processes: Physical attendance at General Body Meetings (AGM) is consistently low, hindering critical policy resolutions.\n"
    "4. Delayed Emergency Transmission: Security personnel lack an instantaneous, zero-latency panic broadcast mechanism to alert residents of fires, thefts, or medical hazards.\n"
    "5. Platform Inconsistency: Different community members use disparate operating systems (Android, iOS), leading to fragmented experiences."
)

add_section("1.3 Objectives & Scope")
doc.add_paragraph(
    "The principal objectives of the Prāngan project are:\n"
    "• To Engineer a Cross-Platform Solution: Utilizing Google's Flutter framework to deliver high-performance native executables for Android, iOS, and the Web from a single unified codebase.\n"
    "• To Implement Role-Based Access Control (RBAC): Gating privileges based on user roles (resident, admin) and validation states (pending, approved, rejected).\n"
    "• To Facilitate Real-Time Community Governance: Building live polling modules with dynamic tally calculation and instant result projection.\n"
    "• To Provide an Instant Crisis Broadcast Subsystem: Developing a zero-delay SOS alerting engine that surfaces critical red banners on all active user devices.\n"
    "• To Maintain Architectural Modularity: Adhering strictly to MVVM and Provider design patterns to ensure maintainability, scalability, and code testability."
)

# ================= CHAPTER 2 =================
add_chapter("CHAPTER 2: LITERATURE SURVEY & COMPARATIVE ANALYSIS")
doc.add_paragraph(
    "During the preliminary research phase, three primary categories of existing community management paradigms were critically examined: Instant Messaging groups (WhatsApp), Commercial Gatekeeper apps (MyGate, NoBrokerHood), and physical circular boards. The comparative matrix below highlights the evaluation results:"
)

# Table for comparison
cmp_table = doc.add_table(rows=1, cols=4)
cmp_table.alignment = WD_TABLE_ALIGNMENT.CENTER
headers = ["Evaluation Metric", "WhatsApp Groups", "Commercial Apps", "PRĀNGAN (Proposed)"]
for i, h in enumerate(headers):
    cell = cmp_table.rows[0].cells[i]
    cell.paragraphs[0].add_run(h).font.bold = True
    set_cell_background(cell, "86243A")
    cell.paragraphs[0].runs[0].font.color.rgb = RGBColor(255, 255, 255)

data = [
    ("Identity Verification & RBAC", "None", "Partial", "Strict Admin Approval Workflow"),
    ("SOS Emergency Broadcast", "Text message only", "Buried in menu", "Prominent Instant Red Banner"),
    ("Real-Time Live Polling", "Basic Poll", "Paid add-on", "Live Dynamic Animated Tallies"),
    ("Grievance / Issue Tracking", "Unstructured", "Proprietary", "Integrated Discussion Forum"),
    ("Data Privacy & Security", "Exposed phone numbers", "Third-party ad tracking", "Encrypted UID-gated data"),
    ("Cross-Platform Support", "Native apps", "Native apps", "Flutter (Android, iOS, Web)")
]

for row_data in data:
    row = cmp_table.add_row()
    for i, val in enumerate(row_data):
        row.cells[i].paragraphs[0].add_run(val)

doc.add_paragraph()

# ================= CHAPTER 3 =================
add_chapter("CHAPTER 3: SYSTEM ARCHITECTURE & DATA DESIGN")
add_section("3.1 MVVM Architecture with Provider")
doc.add_paragraph(
    "Prāngan utilizes the Model-View-ViewModel (MVVM) architecture with the Provider state management paradigm. "
    "The application is partitioned into four distinct layers:\n"
    "1. View Layer (lib/screens/, lib/widgets/): Pure stateless and stateful presentation widgets that consume data reactively.\n"
    "2. ViewModel Layer (lib/providers/): Six specialized ChangeNotifier providers (AuthProvider, SocietyProvider, PostProvider, EventProvider, PollProvider, AlertProvider) that hold app state and broadcast updates via notifyListeners().\n"
    "3. Service Layer (lib/services/): Abstracted Firebase operations isolating raw Firestore and Auth calls from UI widgets.\n"
    "4. Model Layer (lib/models/): Type-safe data schema models implementing factory serialization (fromFirestore, toMap) with Dart 3 Sound Null Safety."
)

add_section("3.2 Cloud Firestore Database Schema")
doc.add_paragraph(
    "The database consists of 5 core collections structured for real-time querying:\n"
    "• users: Document ID: uid. Contains name, email, photoUrl, role (resident/admin), status (pending/approved), and societyId.\n"
    "• societies: Document ID: societyId. Contains society name, description, location, adminUid, and memberCount.\n"
    "• posts: Document ID: postId. Contains authorId, authorName, societyId, content, imageUrl, likes array, and commentCount.\n"
    "• polls: Document ID: pollId. Contains question, options array, votes map {uid: optionIndex}, and createdAt timestamp.\n"
    "• alerts: Document ID: alertId. Contains message, severity (info/warning/sos), societyId, createdBy, and createdAt timestamp."
)

# ================= CHAPTER 4 =================
add_chapter("CHAPTER 4: COMPLETE SCREEN WALKTHROUGH & RESULTS")
doc.add_paragraph(
    "The following section details the fifteen core user interfaces developed in Prāngan, complete with operational descriptions and embedded visual screenshots:"
)

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

screenshot_dir = "/Users/sahilpandey/Desktop/prangan/assets/screenshots"

for img_name, fig_title, fig_desc in screenshots:
    img_path = os.path.join(screenshot_dir, img_name)
    if os.path.exists(img_path):
        p_fig = doc.add_paragraph()
        p_fig.alignment = WD_ALIGN_PARAGRAPH.CENTER
        run_img = p_fig.add_run()
        run_img.add_picture(img_path, width=Inches(3.2))
        
        p_cap = doc.add_paragraph()
        p_cap.alignment = WD_ALIGN_PARAGRAPH.CENTER
        run_cap = p_cap.add_run(f"{fig_title}: {fig_desc}\n")
        run_cap.font.bold = True
        run_cap.font.size = Pt(10)
        run_cap.font.color.rgb = crimson
    else:
        doc.add_paragraph(f"[Screenshot {img_name}]: {fig_desc}")

# ================= CHAPTER 5 =================
add_chapter("CHAPTER 5: TESTING & PERFORMANCE EVALUATION")
doc.add_paragraph(
    "Comprehensive testing was conducted across unit, integration, and security layers. The test execution matrix is summarized below:"
)

test_table = doc.add_table(rows=1, cols=4)
test_table.alignment = WD_TABLE_ALIGNMENT.CENTER
test_headers = ["Test ID", "Test Objective", "Expected Outcome", "Test Status"]
for i, h in enumerate(test_headers):
    cell = test_table.rows[0].cells[i]
    cell.paragraphs[0].add_run(h).font.bold = True
    set_cell_background(cell, "86243A")
    cell.paragraphs[0].runs[0].font.color.rgb = RGBColor(255, 255, 255)

test_cases = [
    ("TC-01", "Google OAuth 2.0 Sign-In", "User token validated, doc created in Firestore", "PASS"),
    ("TC-02", "Email Form Validation", "Invalid email triggers error banner", "PASS"),
    ("TC-03", "Resident Society Attachment", "User doc updated with societyId and pending status", "PASS"),
    ("TC-04", "RBAC Access Gating", "Pending user blocked from Dashboard until approved", "PASS"),
    ("TC-05", "Admin Approval Execution", "Member status changes to approved in Firestore", "PASS"),
    ("TC-06", "Real-Time Auto Unlock", "Resident screen unlocks in <1 second upon approval", "PASS"),
    ("TC-07", "Discussion Post Creation", "Photo uploaded to Storage, post saved to Firestore", "PASS"),
    ("TC-08", "Single Vote Enforcement", "Duplicate vote prevented per user UID", "PASS"),
    ("TC-09", "Dynamic Poll Recalculation", "Vote percentages animate live across client screens", "PASS"),
    ("TC-10", "SOS Emergency Broadcast", "Red banner flashes instantly on connected dashboards", "PASS")
]

for tc in test_cases:
    row = test_table.add_row()
    for i, val in enumerate(tc):
        row.cells[i].paragraphs[0].add_run(val)

doc.add_paragraph()

# ================= CHAPTER 6 =================
add_chapter("CHAPTER 6: CONCLUSION & FUTURE ENHANCEMENTS")
doc.add_paragraph(
    "The Prāngan application successfully demonstrates the application of modern cross-platform mobile development "
    "to solve systemic communication and governance problems within residential and campus communities.\n\n"
    "By replacing chaotic instant messaging groups with a dedicated, role-verified, and real-time synchronized environment, "
    "Prāngan enhances operational transparency, accelerates emergency response, and democratizes collective decision-making.\n\n"
    "Future roadmap plans include:\n"
    "1. Digital Maintenance Collection: Incorporating UPI / Razorpay gateways for automated billing and receipt generation.\n"
    "2. Visitor Gatekeeper QR Passes: Enabling residents to pre-authorize visitor and delivery entries via dynamic QR codes.\n"
    "3. Gemini AI Grievance Categorization: Automatically tagging and prioritizing maintenance tickets using machine learning."
)

# Output path directly to Desktop
desktop_docx = "/Users/sahilpandey/Desktop/PRANGAN_PROJECT_REPORT.docx"
doc.save(desktop_docx)
print(f"Successfully generated DOCX at: {desktop_docx}")
