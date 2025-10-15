# User Account Deletion Setup

## Overview
The app now supports user account deletion. This requires setting up a Supabase Edge Function to properly delete user accounts from Supabase Auth.

## Setup Instructions

### 1. Deploy the Edge Function

The Edge Function is located at `supabase/functions/delete-user-account/index.ts`.

To deploy it:

```bash
# Install Supabase CLI if you haven't already
npm install -g supabase

# Login to Supabase
supabase login

# Link your project
supabase link --project-ref YOUR_PROJECT_REF

# Deploy the function
supabase functions deploy delete-user-account
```

### 2. Set Environment Variables

Make sure your Supabase project has the following environment variables set:

- `SUPABASE_URL`: Your Supabase project URL
- `SUPABASE_SERVICE_ROLE_KEY`: Your Supabase service role key (not the anon key)

### 3. Test the Function

You can test the function using the Supabase CLI:

```bash
supabase functions serve delete-user-account
```

## How It Works

### Without Edge Function (Fallback)
If the Edge Function is not deployed:
1. ✅ Deletes user profile from `profiles` table
2. ✅ Deletes user redemptions from `redemptions` table  
3. ✅ Signs out the user
4. ✅ Clears local data
5. ⚠️ User account remains in Supabase Auth (but inactive)

### With Edge Function (Full Deletion)
If the Edge Function is deployed:
1. ✅ Deletes user profile from `profiles` table
2. ✅ Deletes user redemptions from `redemptions` table
3. ✅ Deletes user account from Supabase Auth
4. ✅ Signs out the user
5. ✅ Clears local data

## Security Notes

- The Edge Function uses the service role key to delete users
- It includes proper CORS headers for web requests
- Error handling ensures the process continues even if some steps fail
- User data is always deleted from the database regardless of Auth deletion success

## Troubleshooting

### Function Not Deployed
If you see "Server function may not be deployed" in the logs:
- Deploy the Edge Function using the instructions above
- Check that your service role key is correctly set

### Permission Errors
If you get permission errors:
- Ensure the service role key has admin privileges
- Check that RLS policies allow the function to delete user data

### Database Errors
If profile/redemption deletion fails:
- Check that the user has the correct permissions
- Verify that the tables exist and have the expected structure
