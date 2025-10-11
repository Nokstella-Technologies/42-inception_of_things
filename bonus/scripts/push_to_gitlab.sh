#!/usr/bin/env bash
set -euo pipefail

echo "===== Pushing Manifests to GitLab ====="

# Configuration
GITLAB_URL="http://gitlab.localhost:8080"
USERNAME="llimace"
PROJECT_NAME="llima-ce"
PASSWORD=t1t2t3t4@



echo ""
echo "GitLab URL: ${GITLAB_URL}"
echo "User: ${USERNAME}"
echo "Project: ${PROJECT_NAME}"
echo ""

echo "Checking if project exists..."
PROJECT_CHECK=$(kubectl exec -n gitlab deployment/gitlab-toolbox -c toolbox -- \
  gitlab-rails runner "
    user = User.find_by_username('${USERNAME}')
    if user.nil?
      puts 'USER_NOT_FOUND'
    else
      project = Project.find_by_full_path('${USERNAME}/${PROJECT_NAME}')
      if project.nil?
        puts 'PROJECT_NOT_FOUND'
      else
        puts 'PROJECT_EXISTS'
      end
    end
  " 2>/dev/null | tail -n 1)

echo "Check result: $PROJECT_CHECK"

if [ "$PROJECT_CHECK" = "USER_NOT_FOUND" ]; then
    echo "Error: User '${USERNAME}' not found in GitLab!"
    echo "Please run setup_gitlab.sh first to create the user."
    exit 1
elif [ "$PROJECT_CHECK" = "PROJECT_NOT_FOUND" ]; then
    echo "Project does not exist. Creating via Rails console..."
    
    # Create project via Rails console
    kubectl exec -n gitlab deployment/gitlab-toolbox -c toolbox -- \
      gitlab-rails runner "
        user = User.find_by_username('${USERNAME}')
        project = Projects::CreateService.new(
          user,
          name: '${PROJECT_NAME}',
          path: '${PROJECT_NAME}',
          visibility_level: Gitlab::VisibilityLevel::PUBLIC,
          initialize_with_readme: false
        ).execute
        
        if project.persisted?
          puts 'Project created successfully!'
        else
          puts 'Error creating project: ' + project.errors.full_messages.join(', ')
        end
      " 2>&1 | grep -v "^$"

      kubectl exec -n gitlab deployment/gitlab-toolbox -c toolbox -- gitlab-rails runner "
        project = Project.find_by_full_path('llimace/llima-ce')
        if project
          project.update(visibility_level: Gitlab::VisibilityLevel::PUBLIC)
          puts 'Repository visibility set to PUBLIC'
          puts 'Project URL: ' + project.http_url_to_repo
        else
          puts 'Project not found'
        end
      " 2>/dev/null
    
    echo "Project created!"
    sleep 3
else
    echo "Project already exists."
fi

# Create temp directory
TEMP_DIR=$(mktemp -d)
rm -rf "$TEMP_DIR"
mkdir "$TEMP_DIR"
cd "$TEMP_DIR"

echo "Preparing manifests..."

git credential approve <<EOF
protocol=https
host=gitlab.localhost:8079
username=${USERNAME}
password=${PASSWORD}
EOF

git clone http://gitlab.localhost:8080/${USERNAME}/${PROJECT_NAME}.git .
# Copy manifests
cp /home/llima-ce/code/42-inception_of_things/bonus/confs/* .

# Configure git
git config --global user.email "${USERNAME}@localhost"
git config --global user.name "llimace"

# Initialize git
git add .
git commit -m "Initial commit: Kubernetes manifests"

echo "Pushing to GitLab..."
git push -u origin main --force 2>&1 || {
    echo "Push failed. Trying alternative method..."
    git push -u origin main 2>&1 || echo "Push may have failed"
}

# Cleanup
cd /
rm -rf "$TEMP_DIR"

echo ""
echo "===== Setup Complete ====="
echo ""
echo "Repository URL: ${GITLAB_URL}/${USERNAME}/${PROJECT_NAME}"
echo "Clone URL: ${GITLAB_URL}/${USERNAME}/${PROJECT_NAME}.git"
echo ""
echo "Next steps:"
echo "1. Verify repository at: ${GITLAB_URL}/${USERNAME}/${PROJECT_NAME}"
echo "2. Update Argo CD Application to use this repository"
echo "3. Run: kubectl apply -f bonus/confs/application.yaml"
echo ""
