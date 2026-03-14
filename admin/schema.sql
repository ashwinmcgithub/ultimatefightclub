-- ================================================================
--  Ultimate Fight Club — Supabase Schema
--  Run this entire file once in:
--  supabase.com → Your Project → SQL Editor → New Query → Run
-- ================================================================

-- 1. CONTACT INFO (always one row)
CREATE TABLE IF NOT EXISTS contact_info (
  id          integer PRIMARY KEY DEFAULT 1,
  phone       text    DEFAULT '+91 77363 76100',
  whatsapp    text    DEFAULT '917736376100',
  email       text    DEFAULT '',
  updated_at  timestamptz DEFAULT now()
);
INSERT INTO contact_info (id) VALUES (1) ON CONFLICT DO NOTHING;

-- 2. BRANCHES / LOCATIONS
CREATE TABLE IF NOT EXISTS branches (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name        text NOT NULL,
  area        text,
  address     text,
  pincode     text,
  maps_url    text,
  image_url   text,
  features    text[],
  is_active   boolean DEFAULT true,
  sort_order  integer DEFAULT 0
);

-- 3. GALLERY
CREATE TABLE IF NOT EXISTS gallery (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  image_url   text NOT NULL,
  title       text,
  category    text DEFAULT 'training',  -- training | competition | facilities | events
  sort_order  integer DEFAULT 0,
  is_active   boolean DEFAULT true,
  created_at  timestamptz DEFAULT now()
);

-- 4. STATS / COUNTERS
CREATE TABLE IF NOT EXISTS stats (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  key         text UNIQUE NOT NULL,
  label       text NOT NULL,
  value       text NOT NULL,
  icon        text,
  color       text DEFAULT 'gold',  -- 'red' | 'gold'
  sort_order  integer DEFAULT 0
);

-- 5. FEE STRUCTURE
CREATE TABLE IF NOT EXISTS fee_structure (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  category        text NOT NULL,   -- 'students' | 'women' | 'gents' | 'other'
  label           text NOT NULL,
  age_group       text,
  original_price  integer,
  offer_price     integer NOT NULL,
  duration        text DEFAULT '2 Months',
  description     text,
  wa_message      text,
  is_active       boolean DEFAULT true,
  sort_order      integer DEFAULT 0
);

-- 6. BANNERS (vacation offer, certification, etc.)
CREATE TABLE IF NOT EXISTS banners (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  type        text UNIQUE NOT NULL,  -- 'vacation_offer' | 'certification' | 'general'
  title       text,
  subtitle    text,
  tag_label   text,
  is_active   boolean DEFAULT true,
  content     jsonb   DEFAULT '{}',
  updated_at  timestamptz DEFAULT now()
);

-- ================================================================
--  ROW LEVEL SECURITY
-- ================================================================
ALTER TABLE contact_info  ENABLE ROW LEVEL SECURITY;
ALTER TABLE branches       ENABLE ROW LEVEL SECURITY;
ALTER TABLE gallery        ENABLE ROW LEVEL SECURITY;
ALTER TABLE stats          ENABLE ROW LEVEL SECURITY;
ALTER TABLE fee_structure  ENABLE ROW LEVEL SECURITY;
ALTER TABLE banners        ENABLE ROW LEVEL SECURITY;

-- Public (anyone) can READ
CREATE POLICY "public_read_contact"  ON contact_info  FOR SELECT USING (true);
CREATE POLICY "public_read_branches" ON branches      FOR SELECT USING (true);
CREATE POLICY "public_read_gallery"  ON gallery       FOR SELECT USING (true);
CREATE POLICY "public_read_stats"    ON stats         FOR SELECT USING (true);
CREATE POLICY "public_read_fees"     ON fee_structure FOR SELECT USING (true);
CREATE POLICY "public_read_banners"  ON banners       FOR SELECT USING (true);

-- Authenticated admin can do everything
CREATE POLICY "admin_all_contact"   ON contact_info  FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "admin_all_branches"  ON branches      FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "admin_all_gallery"   ON gallery       FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "admin_all_stats"     ON stats         FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "admin_all_fees"      ON fee_structure FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "admin_all_banners"   ON banners       FOR ALL USING (auth.role() = 'authenticated');

-- ================================================================
--  STORAGE BUCKET FOR IMAGES
-- ================================================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('site-images', 'site-images', true)
ON CONFLICT DO NOTHING;

CREATE POLICY "public_read_images"  ON storage.objects FOR SELECT  USING (bucket_id = 'site-images');
CREATE POLICY "admin_upload_images" ON storage.objects FOR INSERT  WITH CHECK (bucket_id = 'site-images' AND auth.role() = 'authenticated');
CREATE POLICY "admin_delete_images" ON storage.objects FOR DELETE  USING (bucket_id = 'site-images' AND auth.role() = 'authenticated');

-- ================================================================
--  SEED DATA  (mirrors current hardcoded content)
-- ================================================================

-- Stats
INSERT INTO stats (key, label, value, icon, color, sort_order) VALUES
  ('champions',    'National & State Champions', '28+',  '🏆', 'gold', 1),
  ('state_titles', 'State Titles',               '60+',  '🥇', 'red',  2),
  ('years',        'Years of Excellence',        '15+',  '⚡', 'gold', 3),
  ('students',     'Active Students',            '500+', '👊', 'red',  4)
ON CONFLICT (key) DO NOTHING;

-- Branches
INSERT INTO branches (name, area, address, pincode, maps_url, features, sort_order) VALUES
  ('Aluva Branch',     'Aluva, Ernakulam',      'Main Road, Aluva, Ernakulam, Kerala',          '683101',
   'https://maps.google.com/?q=Ultimate+Fight+Club+Aluva+Ernakulam+Kerala',
   ARRAY['Professional MMA Cage','Heavy Bag Zone','Grappling Mats','Strength & Conditioning'], 1),
  ('Kolenchery Branch','Kolenchery, Ernakulam',  'Near Town Square, Kolenchery, Ernakulam, Kerala','682311',
   'https://maps.google.com/?q=Ultimate+Fight+Club+Kolenchery+Ernakulam+Kerala',
   ARRAY['Boxing Ring','Kickboxing Zone','Open Mat Area','Cardio Zone'], 2);

-- Vacation offer banner
INSERT INTO banners (type, title, subtitle, tag_label, is_active, content) VALUES
  ('vacation_offer',
   '2 MONTH VACATION SPECIAL OFFER',
   'Daily Training • Mon – Sat • All Disciplines Included',
   '🏖️ Limited Time',
   true,
   '[
     {"label":"👦👧 Students","age_group":"Up to 17 Years — Boys & Girls","original_price":7000,"offer_price":5499,"wa_message":"Hi Coach, I am interested in the 2 Month Vacation Special package for Students (Up to 17 years) — daily training Mon–Sat at ₹5,499!"},
     {"label":"👩 Women","age_group":"18 Years & Above","original_price":8000,"offer_price":6499,"wa_message":"Hi Coach, I am interested in the 2 Month Vacation Special package for Women (18+) — daily training Mon–Sat at ₹6,499!"},
     {"label":"👨 Gents","age_group":"18 Years & Above","original_price":9000,"offer_price":6999,"wa_message":"Hi Coach, I am interested in the 2 Month Vacation Special package for Gents (18+) — daily training Mon–Sat at ₹6,999!"}
   ]'::jsonb
  )
ON CONFLICT (type) DO NOTHING;

-- Certification banner (hidden by default — enable when needed)
INSERT INTO banners (type, title, subtitle, tag_label, is_active, content) VALUES
  ('certification',
   '1-YEAR CERTIFICATION PROGRAM',
   'Become a certified MMA trainer under Coach Bibin P Benny',
   '🎓 Now Enrolling',
   false,
   '{"description":"Get internationally certified in MMA training. Limited seats available.","cta_text":"ENQUIRE NOW","wa_message":"Hi Coach, I am interested in the 1-Year MMA Certification Program!"}'::jsonb
  )
ON CONFLICT (type) DO NOTHING;

-- Fee structure
INSERT INTO fee_structure (category, label, age_group, original_price, offer_price, duration, sort_order) VALUES
  ('students', 'Students Package', 'Up to 17 Years — Boys & Girls', 7000, 5499, '2 Months', 1),
  ('women',    'Women Package',    '18 Years & Above',              8000, 6499, '2 Months', 2),
  ('gents',    'Gents Package',    '18 Years & Above',              9000, 6999, '2 Months', 3)
ON CONFLICT DO NOTHING;
