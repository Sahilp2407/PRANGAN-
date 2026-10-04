// Node script to inject rich, authentic Kharghar society demo data into Firestore
const fs = require('fs');

const PROJECT_ID = 'prangan-e2aa1';
const BASE_URL = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents`;

const societies = ['v7BJgGrmldlMspx13Bp0', 'raj_rajeshwari_sec20'];

async function createDoc(collection, docId, fields) {
  const url = `${BASE_URL}/${collection}/${docId}`;
  try {
    const res = await fetch(url, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ fields })
    });
    if (!res.ok) {
      const err = await res.text();
      console.error(`Failed to write ${collection}/${docId}:`, err);
    } else {
      console.log(`✓ Created ${collection}/${docId}`);
    }
  } catch (e) {
    console.error(`Error on ${collection}/${docId}:`, e);
  }
}

async function run() {
  console.log('Seeding demo data into Firestore for societies:', societies);

  for (const socId of societies) {
    const now = new Date();

    // 1. Posts (Discussions)
    const posts = [
      {
        id: `post_${socId}_1`,
        title: 'Night Gate & Security Protocol from 11:00 PM',
        description: 'All visitors, cabs, and late delivery agents after 11:00 PM will require mandatory resident approval via intercom. Main boom barrier will remain down with security guard verification.',
        authorUid: 'user_919975027178',
        authorName: 'Sahil Pandey (Secretary)',
        authorFlat: 'Wing A-303',
        category: 'Security',
        likes: ['user_919975027178', 'user_919876788762', 'resident_3', 'resident_4', 'resident_5'],
        commentCount: 4,
        date: new Date(now.getTime() - 2 * 3600 * 1000)
      },
      {
        id: `post_${socId}_2`,
        title: 'Diwali Celebration & Diya Lighting in Central Garden 🎉',
        description: 'Join us this Sunday evening for grand diya lighting, rangoli competition for children, and community dinner in the central lawn. All resident families are warmly invited!',
        authorUid: 'user_919876788762',
        authorName: 'Ayush Sharma',
        authorFlat: 'Wing B-301',
        category: 'Social',
        likes: ['user_919975027178', 'resident_1', 'resident_2', 'resident_7', 'resident_8', 'resident_9', 'resident_10', 'resident_11'],
        commentCount: 8,
        date: new Date(now.getTime() - 5 * 3600 * 1000)
      },
      {
        id: `post_${socId}_3`,
        title: 'EV 2-Wheeler Charging Points in Basement - Phase 1',
        description: 'MSEDCL approved wiring work begins this Friday in Basement Level 1 (near pillars 14-18). Please move parked two-wheelers during installation hours (10 AM to 5 PM).',
        authorUid: 'admin_patil',
        authorName: 'Rajesh K. Patil',
        authorFlat: 'Wing A-201',
        category: 'Maintenance',
        likes: ['user_919975027178', 'user_919876788762', 'resident_12'],
        commentCount: 3,
        date: new Date(now.getTime() - 14 * 3600 * 1000)
      },
      {
        id: `post_${socId}_4`,
        title: 'Hero 20T Kids Bicycle in Excellent Condition for Sale',
        description: 'Used gently for 8 months. Upgraded to a gear cycle. Complete with training bells and safety helmet. Available for inspection in Wing B parking lot. Asking price: ₹2,200.',
        authorUid: 'resident_iyer',
        authorName: 'Pooja Iyer',
        authorFlat: 'Wing B-704',
        category: 'Buy/Sell',
        likes: ['resident_3', 'resident_4'],
        commentCount: 2,
        date: new Date(now.getTime() - 26 * 3600 * 1000)
      }
    ];

    for (const p of posts) {
      await createDoc('posts', p.id, {
        title: { stringValue: p.title },
        description: { stringValue: p.description },
        authorUid: { stringValue: p.authorUid },
        authorName: { stringValue: p.authorName },
        authorFlat: { stringValue: p.authorFlat },
        societyId: { stringValue: socId },
        category: { stringValue: p.category },
        likes: { arrayValue: { values: p.likes.map(u => ({ stringValue: u })) } },
        commentCount: { integerValue: p.commentCount.toString() },
        timestamp: { timestampValue: p.date.toISOString() }
      });
    }

    // 2. Events
    const events = [
      {
        id: `event_${socId}_1`,
        title: 'Grand Diwali Milan & Cultural Night',
        description: 'Grand community celebration featuring musical performances by society kids, lantern release, sweet distribution, and catered festive dinner at the Clubhouse.',
        date: new Date(now.getTime() + 8 * 24 * 3600 * 1000),
        time: '6:30 PM - 10:30 PM',
        location: 'Clubhouse Lawn & Banquet Hall',
        category: 'Festival',
        interested: ['user_919975027178', 'user_919876788762', 'res_1', 'res_2', 'res_3', 'res_4', 'res_5', 'res_6', 'res_7']
      },
      {
        id: `event_${socId}_2`,
        title: 'Annual General Body Meeting (AGM) 2026',
        description: 'Presentation of annual audited accounts, discussion on solar rooftop net-metering project, and election of two vacancy committee members.',
        date: new Date(now.getTime() + 4 * 24 * 3600 * 1000),
        time: '10:30 AM - 1:00 PM',
        location: 'Community Hall, 1st Floor',
        category: 'Meeting',
        interested: ['user_919975027178', 'res_10', 'res_11', 'res_12', 'res_13']
      },
      {
        id: `event_${socId}_3`,
        title: 'Free Health & Eye Checkup Camp',
        description: 'In association with Apollo Hospital Kharghar: Free BP, Sugar, ECG and Eye screening camp for all residents and domestic house staff.',
        date: new Date(now.getTime() + 15 * 24 * 3600 * 1000),
        time: '8:30 AM - 1:00 PM',
        location: 'Society Club Activity Room',
        category: 'Health',
        interested: ['user_919975027178', 'user_919876788762', 'res_20', 'res_21']
      }
    ];

    for (const ev of events) {
      await createDoc('events', ev.id, {
        title: { stringValue: ev.title },
        description: { stringValue: ev.description },
        date: { timestampValue: ev.date.toISOString() },
        time: { stringValue: ev.time },
        location: { stringValue: ev.location },
        category: { stringValue: ev.category },
        societyId: { stringValue: socId },
        interestedUsers: { arrayValue: { values: ev.interested.map(u => ({ stringValue: u })) } }
      });
    }

    // 3. Polls
    const polls = [
      {
        id: `poll_${socId}_1`,
        question: 'Where should the 4 new EV 2-Wheeler Fast Chargers be installed?',
        postedBy: 'Managing Committee',
        totalVotes: 68,
        endDate: new Date(now.getTime() + 6 * 24 * 3600 * 1000),
        status: 'active',
        options: [
          { id: 'opt_1', text: 'Ground Level Visitor Parking Bay', voteCount: 32 },
          { id: 'opt_2', text: 'Basement 1 (Near Lift Lobby A)', voteCount: 24 },
          { id: 'opt_3', text: 'Basement 2 (North Open Section)', voteCount: 12 }
        ],
        votedUsers: {
          'user_919975027178': 'opt_1',
          'user_919876788762': 'opt_1'
        }
      },
      {
        id: `poll_${socId}_2`,
        question: 'Should society gym morning hours be extended to 5:30 AM?',
        postedBy: 'Sports & Clubhouse Committee',
        totalVotes: 54,
        endDate: new Date(now.getTime() + 10 * 24 * 3600 * 1000),
        status: 'active',
        options: [
          { id: 'opt_a', text: 'Yes, open from 5:30 AM (Preferred)', voteCount: 38 },
          { id: 'opt_b', text: 'Keep current 6:30 AM timing', voteCount: 10 },
          { id: 'opt_c', text: 'Extend night hours till 11:00 PM instead', voteCount: 6 }
        ],
        votedUsers: {
          'user_919876788762': 'opt_a'
        }
      }
    ];

    for (const poll of polls) {
      const optionsValues = poll.options.map(opt => ({
        mapValue: {
          fields: {
            id: { stringValue: opt.id },
            text: { stringValue: opt.text },
            voteCount: { integerValue: opt.voteCount.toString() }
          }
        }
      }));

      const votedUsersFields = {};
      for (const [k, v] of Object.entries(poll.votedUsers)) {
        votedUsersFields[k] = { stringValue: v };
      }

      await createDoc('polls', poll.id, {
        question: { stringValue: poll.question },
        options: { arrayValue: { values: optionsValues } },
        totalVotes: { integerValue: poll.totalVotes.toString() },
        societyId: { stringValue: socId },
        postedBy: { stringValue: poll.postedBy },
        endDate: { timestampValue: poll.endDate.toISOString() },
        status: { stringValue: poll.status },
        votedUsers: { mapValue: { fields: votedUsersFields } }
      });
    }

    // 4. Alerts
    const alerts = [
      {
        id: `alert_${socId}_1`,
        title: 'CIDCO Main Pipeline Maintenance - Water Timing Update',
        description: 'CIDCO water supply will be restricted on Saturday from 10:00 AM to 5:00 PM due to pipeline repair at Sector 12. Society overhead tanks have been pre-filled. Please use water mindfully.',
        type: 'urgent',
        timestamp: new Date(now.getTime() - 1 * 3600 * 1000),
        readBy: []
      },
      {
        id: `alert_${socId}_2`,
        title: 'Lift No. 2 Preventive Maintenance (Wing B)',
        description: 'Otis technicians will conduct quarterly cable lubrication and safety brake testing between 2:00 PM to 4:30 PM today. Service lift will remain functional.',
        type: 'maintenance',
        timestamp: new Date(now.getTime() - 8 * 3600 * 1000),
        readBy: ['user_919975027178']
      },
      {
        id: `alert_${socId}_3`,
        title: 'External Building Pressure Wash & Painting Completed',
        description: 'Perimeter pressure washing and external festive lighting work has been successfully completed for the season. Thanks to all residents for your cooperation.',
        type: 'notice',
        timestamp: new Date(now.getTime() - 24 * 3600 * 1000),
        readBy: ['user_919975027178', 'user_919876788762']
      }
    ];

    for (const al of alerts) {
      await createDoc('alerts', al.id, {
        title: { stringValue: al.title },
        description: { stringValue: al.description },
        type: { stringValue: al.type },
        societyId: { stringValue: socId },
        timestamp: { timestampValue: al.timestamp.toISOString() },
        readBy: { arrayValue: { values: al.readBy.map(u => ({ stringValue: u })) } }
      });
    }
  }

  console.log('✅ Finished seeding all demo data into Firestore successfully!');
}

run();
