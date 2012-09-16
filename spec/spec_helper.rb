require_relative '../lib/rhubarb'

module Helpers
  def cleanse_live
    @live_dir       = File.join(File.dirname(__FILE__), 'live')
    @canon_dir      = File.join(File.dirname(__FILE__), 'canon')
    @live_files     = File.join(@live_dir, '*')
    @canon_files    = File.join(@canon_dir, '*')
    @stg_batch_home = File.join(@live_dir, 'uaf-stg')

    # Delete everything in 'live'
    FileUtils.rm_rf Dir.glob(@live_files)

    # Copy from 'canon' to 'live'
    FileUtils.cp_r Dir.glob(@canon_files), @live_dir
  end
end