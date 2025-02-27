#!/usr/bin/env ruby

require 'active_support/all'


############## options ########################################################
require 'optparse'

$options = {skip_fetch: false, check_submodules_not_ahead: false}
OptionParser.new do |parser|
  parser.banner = "git-check-ahead-of-origin-master [options]"
  parser.on("-k", "--skip-fetch", "Skip fetching origin/master") do
    $options[:skip_fetch] = true
  end
  parser.on(nil, "--check-submodules-not-ahead", "Check if all submodules are merged to origin/master") do
    $options[:check_submodules_not_ahead] = true
  end
  parser.on("-h", "--help") do
    puts parser
    exit 0
  end
end.parse!


############## main ###########################################################


ALL_REPOS= `git submodule status --recursive`.split("\n").map{|sub| sub.strip.split(/\s+/).map(&:strip)}.map(&:second).append(".").sort()
BEHIND_AHEAD= ALL_REPOS.map { |repo|
  `git -C #{repo} fetch origin master` unless $options[:skip_fetch]
  [repo, `git -C #{repo} rev-list --left-right --count origin/master...HEAD` \
    .split(/\s/).map(&:to_i)].flatten
}

$behind_agg = 0
$ahead_agg = 0

def main
  print("###############################################################################\n")
  print("behind ahead repo\n")
  BEHIND_AHEAD.each do |repo, behind, ahead|
    printf("   %3d   %3d %s\n", behind, ahead, repo )
    $behind_agg += (behind == 0 ? 0 : 1)
    if $options[:check_submodules_not_ahead] && repo != "."
      $ahead_agg += (ahead == 0 ? 0 : 1)
    end
  end
  print("behind ahead repo\n")
  print("###############################################################################\n")
  if $behind_agg > 0
    puts "ERROR: no HEAD must be behind master <=> behind values must all be zero"
  end
  if $options[:check_submodules_not_ahead] && $ahead_agg > 0
    puts "ERROR some submodules are not on 'origin/master', check ahead values above!"
  end
  if $behind_agg + $ahead_agg == 0
    puts "ALL OK"
  end
  exit $behind_agg + $ahead_agg
end

main()
