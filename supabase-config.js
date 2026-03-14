// ================================================================
//  Supabase Configuration — Ultimate Fight Club
//  Replace the two values below with your actual project credentials
//  Found at: supabase.com → Your Project → Settings → API
// ================================================================

const SUPABASE_URL  = 'YOUR_SUPABASE_PROJECT_URL';   // e.g. https://abcxyz.supabase.co
const SUPABASE_ANON = 'YOUR_SUPABASE_ANON_KEY';      // starts with eyJ...

// Shared client used by every page and the admin panel
const sb = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON);
