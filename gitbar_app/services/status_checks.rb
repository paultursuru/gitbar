# frozen_string_literal: true

# StatusChecks
# Unifies GitHub's two distinct commit-state systems into one vocabulary:
#   1. Commit Statuses (legacy)  -> external CI POSTs on /statuses/{sha}
#   2. Check Runs (Checks API)   -> GitHub Actions, /commits/{ref}/check-runs
# Both are normalized to 'success' / 'failure' / 'pending' and can be
# aggregated into a single overall state.
module StatusChecks
  module_function

  # Check-run conclusions that must NOT be treated as a failure.
  # neutral/skipped are non-blocking; success obviously passes.
  NON_FAILING_CONCLUSIONS = %w[success neutral skipped].freeze
  # Check-run conclusions that count as a failure.
  FAILING_CONCLUSIONS = %w[failure timed_out cancelled action_required startup_failure stale].freeze

  # Map a single check-run (status + conclusion) to success/failure/pending.
  # queued / in_progress / waiting / requested means it has not finished yet.
  def check_run_state(status:, conclusion:)
    return 'pending' unless status.to_s.downcase == 'completed'

    case conclusion.to_s.downcase
    when *NON_FAILING_CONCLUSIONS then 'success'
    when *FAILING_CONCLUSIONS then 'failure'
    else 'pending'
    end
  end

  # Map a legacy commit-status state to success/failure/pending.
  # 'error' is treated as a failure; anything unfinished stays pending.
  def commit_status_state(state)
    case state.to_s.downcase
    when 'success' then 'success'
    when 'failure', 'error' then 'failure'
    else 'pending'
    end
  end

  # Aggregate normalized states into one overall state.
  # failure if any failed; pending if any still running; success otherwise.
  # Returns nil when there is nothing to aggregate.
  def aggregate(states)
    return nil if states.empty?
    return 'failure' if states.include?('failure')
    return 'pending' if states.include?('pending')

    'success'
  end

  # Normalize REST check-run objects (commits/{ref}/check-runs) into the same
  # shape as legacy commit "statuses[]" entries, so the view can render both
  # the same way (description / state / target_url / created_at).
  def normalize_check_runs(check_runs)
    check_runs.map do |run|
      {
        'description' => run['name'],
        'state' => check_run_state(status: run['status'], conclusion: run['conclusion']),
        'target_url' => run['details_url'] || run['html_url'],
        'created_at' => run['started_at'] || run['completed_at']
      }
    end
  end
end
