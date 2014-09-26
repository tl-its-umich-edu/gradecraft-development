GradeCraft::Application.routes.draw do

  require 'sidekiq/web'
  require 'admin_constraint'
  mount Sidekiq::Web => '/sidekiq', :constraints => AdminConstraint.new
  mount Bootsy::Engine => '/bootsy', as: 'bootsy'
  #1. Analytics & Charts
  #2. Assignments, Submissions, Tasks, Grades
  #3. Assignment Types
  #4. Assignment Type Weights
  #5. Badges
  #6. Challenges
  #7. Courses
  #8. Groups
  #9. Informational Pages
  #10. Rubrics & Grade Schemes
  #11. Teams
  #12. Users
  #13. User Auth
  #14. Uploads

  #1. Analytics & Charts
  namespace :analytics do
    root :to => :index
    get :staff
    get :students
    get :top_10
    get :teams
    get :team_grade
    get :per_assign
    get :all_events
    get :role_events
    get :assignment_events
    get :login_frequencies
    get :role_login_frequencies
    get :login_events
    get :login_role_events
    get :all_pageview_events
    get :all_role_pageview_events
    get :all_user_pageview_events
    get :pageview_events
    get :role_pageview_events
    get :user_pageview_events
    get :prediction_averages
    get :assignment_prediction_averages
  end

  post 'analytics_events/predictor_event'
  post 'analytics_events/tab_select_event'

  #2. Assignments, Submissions, Tasks, Grades
  resources :assignments do
    collection do
      get :feed
      get :settings
      post 'copy' => 'assignments#copy'
      get 'weights' => 'assignment_weights#mass_edit', :as => :mass_edit_weights
    end
    member do
      get 'mass_grade' => 'grades#mass_edit', as: :mass_grade
      put 'mass_grade' => 'grades#mass_update'
      get 'group_grade' => 'grades#group_edit', as: :group_grade
      put 'group_grade' => 'grades#group_update'
      get 'export_grades'
      get 'sample_import' => 'assignments#sample_import'
      get 'sample_import_2' => 'assignments#sample_import_2'
      get 'detailed_grades' => 'assignments#show', detailed: true
      scope 'grades', as: :grades, controller: :grades do
        post :edit_status
        put :update_status
        post :self_log
        post :predict_score
        get :import
        post :upload
        post :upload2
      end
    end
    resources :submissions do
      post :upload
    end
    resources :tasks
    resource :grade, only: [:show, :edit, :update, :destroy] do

      put :submit_rubric, on: :collection
      resources :earned_badges
    end
    resource :rubric do
      resources :metrics
      get :design, on: :collection
    end
  end

  resources :metrics do
    put :update_order, on: :collection
  end

  resources :tiers
  resources :graded_metrics

  resources :metric_badges
  resources :tier_badges

  resources :score_levels

  #3. Assignment Types
  resources :assignment_types do
    member do
      get 'all_grades'
    end
  end


  #4. Assignment Type Weights
  get 'assignment_type_weights' => 'assignment_type_weights#mass_edit', as: :assignment_type_weights
  put 'assignment_type_weights' => 'assignment_type_weights#mass_update'

  resources :assignment_weights

  #5. Badges
  resources :badges do
    resources :tasks
    resources :earned_badges do
      post :toggle_shared
      collection do
        get :chart
      end
    end
    member do
      get 'mass_award' => 'earned_badges#mass_edit', as: :mass_award
      put 'mass_award' => 'earned_badges#mass_update'
    end
  end

  #6. Challenges
  resources :challenges do
    resources :challenge_grades do
      collection do
        post :edit_status
        put :update_status
        get :mass_edit

      end
    end
    member do
      get 'mass_edit' => 'challenge_grades#mass_edit', as: :mass_edit
      put 'mass_edit' => 'challenge_grades#mass_update'
    end
    resources :challenge_files do
      get :remove
    end
  end

  #7. Courses
  resources :courses do
    collection do
      post 'copy' => 'courses#copy'
    end
  end
  resources :course_memberships

  post '/current_course/change' => 'current_courses#change', :as => :change_current_course
  get 'current_course' => 'current_courses#show'
  get  'class_badges' => 'students#class_badges'

  get 'leaderboard' => 'info#leaderboard'
  get 'multiplier_choices' => 'info#choices'
  get 'earned_badges' => 'info#class_badges'
  get 'grading_status' => 'info#grading_status'
  get 'gradebook' => 'info#gradebook'
  get 'research_gradebook' => 'info#research_gradebook'

  #8. Groups
  resources :groups do 
    collection do
      get :review
    end  
    resources :proposals
  end
  resources :group_memberships

  #9. Informational Pages
  namespace :info do
    get :all_grades
    get :choices
    get :class_badges
    get :dashboard
    get :grading_status
    get :leaderboard
  end

  resources :home

  get 'using_gradecraft' => 'pages#using_gradecraft'
  get 'contact' => 'pages#contact'
  get 'ping' => 'pages#ping'

  #10. Rubrics & Grade Schemes
  resources :rubrics

  #11. Rubrics & Grade Schemes
  resources :grade_scheme_elements do
    collection do
      post :destroy_multiple
      get 'mass_edit' => 'grade_scheme_elements#mass_edit', as: :mass_edit
      put 'mass_edit' => 'grade_scheme_elements#mass_update'
    end
  end

  #11. Teams
  resources :teams do
    collection do
      get :activity
    end
    resources :earned_badges
  end

  get 'home/index'
  get 'dashboard' => 'info#dashboard'
  root :to => "home#index"

  #12. Users
  %w{students gsis professors admins}.each do |role|
    get "users/#{role}/new" => 'users#new', :as => "new_#{role.singularize}", :role => role.singularize
  end

  resources :users do
    collection do
      get :edit_profile
      get :all
      put :update_profile
      get :test
      get :import
      post :upload
      get :analytics
    end
  end
  resources :students do
    get :grade_index
    get :timeline
    get :syllabus
    get :calendar
    get :badges
    get :predictor
    get :course_progress
    get :teams
    collection do
      get :leaderboard
      get :choices
      get :scores_for_current_course
      get :scores_by_assignment
      get :scores_by_team
      get :scores_for_single_assignment
      get :final_grades
      get :class_badges
    end
  end
  resources :staff, only: [:index, :show]
  resources :user_sessions
  resources :password_resets


  get 'calendar' => 'students#calendar'
  get 'timeline' => 'students#timeline'
  get 'badges' => 'students#badges'
  get 'calendar' => 'students#calendar'
  get 'predictor' => 'students#predictor'
  get 'syllabus' => 'students#syllabus'
  get 'course_progress' => 'students#course_progress'
  get 'my_badges' => 'students#badges'
  get 'my_team' => 'students#teams'

  #13. User Auth
  post 'auth/kerberos/callback', to: 'user_sessions#kerberos_create', as: :auth_kerberos_callback
  match 'auth/lti/callback', to: 'user_sessions#lti_create', via: [:get, :post]
  get 'auth/failure' => 'pages#auth_failure', as: :auth_failure

  get 'login' => 'user_sessions#new', :as => :login
  get 'logout' => 'user_sessions#destroy', :as => :logout
  get 'reset' => 'user_sessions#new'


  get 'lti/:provider/launch', to: 'lti#launch', :as => :launch_lti_provider

  # get 'cosign_test' => 'info#cosign_test'

  #14. Uploads
  resource :uploads do
    get :remove
  end
end
