class SurveysModuleController < ResourceController
  self.tabs = { "Surveys" => "/surveys/surveys", "Questions" => "/surveys/questions" }
end
