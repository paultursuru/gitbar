require 'date'

module ApplicationHelper
  def main_status_icon(repository:)
    return '😊' if repository.my_prs.empty? || repository.my_prs.all? { |pr| pr.reviews.empty? }
  
    groups = repository.my_prs.group_by { |pr| pr.can_be_merged? }
    refused_count = groups[false] ? groups[false].count { |pr| pr.reviews.any? { |review| review.state == 'CHANGES_REQUESTED' } } : 0
    groups[true] ? (groups[true].count > refused_count ? '🟢' : '🔴') : '🟠'
  end
  
  def main_status_text(repository:)
    return 'No open PRs' if repository.my_prs.empty?
  
    groups = repository.my_prs.group_by { |pr| pr.can_be_merged? }
    true_count = groups[true] ? groups[true].count : 0
    false_count = groups[false] ? groups[false].count { |pr| pr.reviews.any? { |review| review.state == 'CHANGES_REQUESTED' } } : 0
    text = "#{true_count} PR#{true_count > 1 ? 's' : ''} can be merged"
    text += " and #{false_count} have changes requested" if false_count > 0
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
  
  def status_color(pr)
    return 'green' if pr.status_check_rollup_state.nil?

    case pr.status_check_rollup_state
    when 'SUCCESS'
      'green'
    when 'FAILURE'
      'red'
    else
      'yellow'
    end
  end
  
  def status_text(pr)
    return 'No status' if pr.status_check_rollup_state.nil?

    "#{pr.status_check_rollup_state&.downcase&.capitalize} #{pr.status_check_rollup_context}"
  end

  def format_pr(pr)
    "#{pr.title.chars.first(40).join}#{pr.title.chars.length > 40 ? '...' : ''} by #{pr.author} (##{pr.number})"
  end

  def mergeable_color(pr)
    case pr.mergeable
    when 'MERGEABLE'
      'green'
    when 'CONFLICTING'
      'red'
    else
      'yellow'
    end
  end
  
  def mergeable_text(pr)
    case pr.mergeable
    when 'MERGEABLE'
      'No conflict'
    when 'CONFLICTING'
      'Conflicts'
    else
      pr.mergeable.downcase.capitalize
    end
  end

  def time_since(updated_at)
    date_now = DateTime.now
    date_updated = DateTime.parse(updated_at)
    difference_in_minutes = ((date_now - date_updated) * 24 * 60).to_i
    if difference_in_minutes < 60
      "Dernier update il y a #{difference_in_minutes} minutes"
    elsif difference_in_minutes < 60 * 24
      "Dernier update il y a #{difference_in_minutes / 60} heures"
    else
      "Dernier update il y a #{difference_in_minutes / 60 / 24} jours"
    end
  end

  def review_icon(pr_review)
    case pr_review.state
    when 'APPROVED'
      '✅'
    when 'CHANGES_REQUESTED'
      '❌'
    else
      '⚠️'
    end
  end

  def review_color(pr_review)
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