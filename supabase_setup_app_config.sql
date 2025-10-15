-- Create app_config table for storing application configuration
CREATE TABLE IF NOT EXISTS app_config (
  id INTEGER PRIMARY KEY DEFAULT 1,
  credit_earning_percentage DECIMAL(5,4) DEFAULT 0.1,
  ad_earning_multiplier DECIMAL(5,4) DEFAULT 1.0,
  survey_earning_multiplier DECIMAL(5,4) DEFAULT 1.0,
  daily_checkin_bonus DECIMAL(5,2) DEFAULT 1.0,
  referral_bonus DECIMAL(5,2) DEFAULT 5.0,
  minimum_redemption_amount DECIMAL(5,2) DEFAULT 15.0,
  max_daily_earning_limit DECIMAL(5,2) DEFAULT 50.0,
  maintenance_mode BOOLEAN DEFAULT false,
  app_version VARCHAR(20) DEFAULT '1.0.0',
  feature_flags JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert default configuration
INSERT INTO app_config (
  id,
  credit_earning_percentage,
  ad_earning_multiplier,
  survey_earning_multiplier,
  daily_checkin_bonus,
  referral_bonus,
  minimum_redemption_amount,
  max_daily_earning_limit,
  maintenance_mode,
  app_version,
  feature_flags
) VALUES (
  1,
  0.1,  -- 10% credit earning percentage
  1.0,  -- 1x ad earning multiplier
  1.0,  -- 1x survey earning multiplier
  1.0,  -- 1 credit daily check-in bonus
  5.0,  -- 5 credits referral bonus
  15.0, -- 15 credits minimum redemption
  50.0, -- 50 credits max daily earning
  false, -- maintenance mode off
  '1.0.0', -- app version
  '{
    "daily_checkin_enabled": true,
    "referral_system_enabled": true,
    "achievement_system_enabled": true,
    "video_ads_enabled": true,
    "survey_system_enabled": true,
    "redemption_system_enabled": true,
    "notifications_enabled": true,
    "analytics_enabled": true
  }'::jsonb
) ON CONFLICT (id) DO NOTHING;

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_app_config_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_app_config_updated_at_trigger
  BEFORE UPDATE ON app_config
  FOR EACH ROW
  EXECUTE FUNCTION update_app_config_updated_at();

-- Grant necessary permissions
GRANT SELECT, INSERT, UPDATE ON app_config TO authenticated;
GRANT SELECT, INSERT, UPDATE ON app_config TO anon;

-- Create RLS policies
ALTER TABLE app_config ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to read config
CREATE POLICY "Allow authenticated users to read app config" ON app_config
  FOR SELECT TO authenticated
  USING (true);

-- Allow authenticated users to update config (admin only in practice)
CREATE POLICY "Allow authenticated users to update app config" ON app_config
  FOR UPDATE TO authenticated
  USING (true);

-- Allow anon users to read config (for public settings)
CREATE POLICY "Allow anon users to read app config" ON app_config
  FOR SELECT TO anon
  USING (true);
