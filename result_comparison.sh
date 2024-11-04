# Defining the report directory path
report_dir="/mnt/c/Users/Sefinat/workspace3/machine_learning_project/report_folder"
csv_file="$report_dir/baseline_model_results.csv"
echo "Trying to open CSV file: $csv_file"
# Function to extract best model by F1-score
extract_best_model_info() {
  # Use awk to process baseline_model_results.csv
  awk -F ',' '{ if ($4 > best_f1) { best_f1 = $4; data_version = $1; model_name = $2; best_metrics = $0 } } END { print data_version, model_name, best_metrics }' "$csv_file"
}

# Find the best model
best_model_info=$(extract_best_model_info)


# Check if a best model was found
if [[ ! -f "$report_dir/baseline_model_results.csv" ]]; then
  echo "Error: baseline_model_results.csv not found in $report_dir"
  exit 1
fi

if [[ -z "$best_model_info" ]]; then
  echo "Error: No best model found in baseline_model_results.csv"
  exit 1
fi


# Extract metrics (assuming comma separation)
data_version=$(echo "$best_model_info" | cut -d ' ' -f1)
model_name=$(echo "$best_model_info" | cut -d ' ' -f2)
f1_score=$(echo "$best_model_info" | cut -d ' ' -f3)
accuracy=$(echo "$best_model_info" | cut -d ' ' -f4)
precision=$(echo "$best_model_info" | cut -d ' ' -f5)
recall=$(echo "$best_model_info" | cut -d ' ' -f6)
roc_auc=$(echo "$best_model_info" | cut -d ' ' -f7)
log_loss=$(echo "$best_model_info" | cut -d ' ' -f8)

# Generate Markdown report header
report_content="# Baseline Model Report\n\n"

# Add data version information
report_content="$report_content## Data Version: $data_version\n\n"

# Add model name information
report_content="$report_content## Model Name: $model_name\n\n"

# Add key performance metrics
report_content="$report_content## Key Performance Metrics\n\n"
report_content="$report_content* F1-Score: $f1_score\n"
report_content="$report_content* Accuracy: $accuracy\n"
report_content="$report_content* Precision: $precision\n"
report_content="$report_content* Recall: $recall\n"
report_content="$report_content* ROC AUC: $roc_auc\n"
report_content="$report_content* Log Loss: $log_loss\n"


# Add confusion matrix information 
confusion_matrix_file="$report_dir/$data_version-$model_name_confusion_matrix.png"
if [[ -f "$confusion_matrix_file" ]]; then
  report_content="$report_content## Confusion Matrix\n\n"
  report_content="$report_content![Confusion Matrix]($confusion_matrix_file)\n"
fi

# Generate the Markdown report
echo -e "$report_content" > "$report_dir/baseline_model_report.md"

report_content="$report_content## Confusion Matrix\n\n"
report_content="$report_content![Confusion Matrix](report_folder/LogisticRegression_confusion_matrix.png)"
# Add, commit, and push changes
git add "$report_dir/baseline_model_report.md"
git commit -m "Added baseline model report"
git push origin compare-result

echo "Baseline model report generated and pushed to compare-result branch."

