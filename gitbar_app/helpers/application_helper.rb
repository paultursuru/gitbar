require 'date'

# ApplicationHelper
# View helpers used by Gitbar to format status icons, colors, and text
# for repositories and pull requests in the SwiftBar/BitBar output.
module ApplicationHelper
  def main_status_icon(repository:)
    return '😊' if repository.my_prs.empty? || repository.my_prs.all? { |pr| pr.reviews.empty? }

    status_icon(status: repository.status)
  end

  def main_status_text(repository:)
    return 'No open PRs' if repository.my_prs.empty?

    groups = repository.my_prs.group_by { |pr| pr.can_be_merged? }
    text = repository.simple_name
    text += ready_to_merge_counters(groups: groups)
    text += " • #{repository.review_requested_prs.count} 👀" if repository.review_requested_prs.count > 0
    text
  end

  def ready_to_merge_counters(groups:)
    true_count = groups[true] ? groups[true].count : 0
    false_count = groups[false] ? groups[false].count { |pr| pr.reviews.any? { |review| review.state == 'CHANGES_REQUESTED' } } : 0
    text = ''
    text += " • #{true_count} ✅" if true_count > 0
    text += " • #{false_count} ❌" if false_count > 0
    text
  end

  def status_icon(status:)
    return '🟢' if status.nil?

    case status.downcase
    when 'success', 'mergeable'
      '🟢'
    when 'failure', 'conflicting'
      '🔴'
    else
      '🟠'
    end
  end

  def status_color(pull_request:)
    return 'green' if pull_request&.status_check_rollup_state&.nil?

    case pull_request.status_check_rollup_state
    when 'SUCCESS'
      'green'
    when 'FAILURE'
      'red'
    else
      'yellow'
    end
  end

  def status_text(pull_request:)
    return 'No status' if pull_request&.status_check_rollup_state&.nil?

    "#{pull_request.status_check_rollup_state&.downcase&.capitalize} #{pull_request.status_check_rollup_context}"
  end

  def format_pr(pull_request:)
    return '' if pull_request&.title&.nil?

    "#{pull_request.title.chars.first(40).join}#{pull_request.title.chars.length > 40 ? '...' : ''} by #{pull_request.author} (##{pull_request.number})"
  end

  def mergeable_color(pull_request:)
    return 'yellow' if pull_request&.mergeable&.nil?

    case pull_request.mergeable
    when 'MERGEABLE'
      'green'
    when 'CONFLICTING'
      'red'
    else
      'yellow'
    end
  end

  def mergeable_text(pull_request:)
    return 'No conflict' if pull_request&.mergeable&.nil?

    case pull_request.mergeable
    when 'MERGEABLE'
      'No conflict'
    when 'CONFLICTING'
      'Conflicts'
    else
      pull_request.mergeable.downcase.capitalize
    end
  end

  def time_since(updated_at:)
    return 'No update' if updated_at.nil?

    difference_in_minutes = ((DateTime.now - DateTime.parse(updated_at)) * 24 * 60).to_i
    if difference_in_minutes < 60
      "Dernier update il y a #{difference_in_minutes} minutes"
    elsif difference_in_minutes < 60 * 24
      "Dernier update il y a #{difference_in_minutes / 60} heures"
    else
      "Dernier update il y a #{difference_in_minutes / 60 / 24} jours"
    end
  end

  def review_icon(pr_review:)
    return '⚠️' if pr_review&.state&.nil?

    case pr_review.state
    when 'APPROVED'
      '✅'
    when 'CHANGES_REQUESTED'
      '❌'
    else
      '⚠️'
    end
  end

  def review_color(pr_review:)
    return 'yellow' if pr_review&.state&.nil?

    case pr_review.state
    when 'APPROVED'
      'green'
    when 'CHANGES_REQUESTED'
      'red'
    else
      'yellow'
    end
  end
end
