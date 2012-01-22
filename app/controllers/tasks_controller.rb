class TasksController < ApplicationController

  def show
    @lang = Language.find(params[:language_id])
    @task = @lang.tasks.where(slug: params[:id]).first

    if has_access? @task
      @submissions = current_user.submissions_for_task(@task).page(params[:page]).per(5)
      styx_initialize_with :cm_mode => @lang.cm_mode.presence
    else
      redirect_to :root
    end
  end

  def submit
    task = Task.where(language_id: params[:language_id], slug: params[:id]).first

    submission = Submission.create(
        :task   => task,
        :user   => current_user,
        :result => :testing,
        :source => params[:source],
        :time   => DateTime.now
    )

    render :json => { :submission_id => submission.id, :time => submission.time.strftime('%H:%M:%S %d %b') }
  end

  def check_submissions
    ids = params['ids'] || []
    response = ids.map do |id|
      submission = Submission.find(id)
      elapsed = ((DateTime.now - submission.time) * 24 * 60 * 60).to_i
      if elapsed > 10
        submission.result = (rand 2).even? ? :accepted : :failed
        submission.save
        if submission.result == :accepted
          submission.user.task_accepted submission.task
        else
          submission.user.task_failed submission.task
        end
      end
      result = { :result => submission.result, :id => id }
      if submission.result == :failed
        result.merge!({ :reason => submission.fail_cause })
      end
      result
    end
    render :json => response
  end

  private

  def has_access?(task)
    current_user && current_user.has_language?(task.language)
  end
end
