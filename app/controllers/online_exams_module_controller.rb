class OnlineExamsModuleController < ResourceController
  self.tabs = { "Tests" => "/online-exams/tests", "Questions" => "/online-exams/questions", "Attempts" => "/online-exams/attempts" }
end
