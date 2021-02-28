#!/bin/bash
set -e

# Set options based on user input
if [ -z "$INPUT_DESTINATION_PATH" ]; then
	DESTINATION_PATH="./languages"
else
	DESTINATION_PATH=$INPUT_DESTINATION_PATH
fi

if [ -z "$INPUT_SLUG" ]; then
	SLUG=${GITHUB_REPOSITORY#*/}
else
	SLUG=$INPUT_SLUG
fi

if [ -z "$INPUT_TEXT_DOMAIN" ]; then
	TEXT_DOMAIN=$SLUG
else
	TEXT_DOMAIN=$INPUT_TEXT_DOMAIN
fi

if [ -z "$PAT_TOKEN" ]; then
	TOKEN=$GITHUB_TOKEN
else
	TOKEN=$PAT_TOKEN
fi

POT_PATH="$DESTINATION_PATH/$TEXT_DOMAIN.pot"
echo "✔️ DESTINATION_PATH: $DESTINATION_PATH"
echo "✔️ SLUG : $SLUG"
echo "✔️ TEXT_DOMAIN: $TEXT_DOMAIN"

if [ ! -d "$DESTINATION_PATH" ]; then
	mkdir -p $DESTINATION_PATH
fi

# Setup Git config and push .pot file to github repo
git config --global user.name "WordPress .pot File Generator"
git config --global user.email "41898282+github-actions[bot]@users.noreply.github.com"

REPO_NAME="$GITHUB_REPOSITORY"
if [ "$GITHUB_EVENT_NAME" == "pull_request" ]; then
	FORK=$(cat "$GITHUB_EVENT_PATH" | jq .pull_request.head.repo.fork)
	MODIFY=$(cat "$GITHUB_EVENT_PATH" | jq .pull_request.maintainer_can_modify)
	if [ "$FORK" == true ]; then
		REPO_NAME=$(cat "$GITHUB_EVENT_PATH" | jq .pull_request.head.repo.full_name | cut -d "\"" -f 2)
		REMOTE=$(cat "$GITHUB_EVENT_PATH" | jq .pull_request.head.repo.clone_url | cut -d "\"" -f 2)
	else
		REMOTE="origin"
	fi

	if [ "$FORK" == true ] && [ "$MODIFY" == false ]; then
		echo "🚫 PR can't be modified by maintainer"
	fi

	echo "✔️ GITHUB_EVENT_PATH: $GITHUB_EVENT_PATH"
	echo "✔️ FORK: $FORK"
	echo "✔️ MODIFY : $MODIFY"
	echo "✔️ REMOTE: $REMOTE"
	echo "✔️ BRANCH: $GITHUB_HEAD_REF"

	# Checkout to PR branch
	git fetch "$REMOTE" "$GITHUB_HEAD_REF:$GITHUB_HEAD_REF"
	git config "branch.$GITHUB_HEAD_REF.remote" "$REMOTE"
	git config "branch.$GITHUB_HEAD_REF.merge" "refs/heads/$GITHUB_HEAD_REF"
	git checkout "$GITHUB_HEAD_REF"
fi

# Generate POT file.
echo "🔨 Generating POT file"
wp i18n make-pot . "$POT_PATH" --domain="$TEXT_DOMAIN" --slug="$SLUG" --allow-root --color

# Push file to repository.
if [ "$(git status $POT_PATH --porcelain)" != "" ]; then
	echo "🔼 Pushing to repository"
	git add "$POT_PATH"
	git commit -m "🔄 Generated POT File"
	if [ "$FORK" == true ]; then
		echo "debug: $REPO_NAME"
		git config credential.https://github.com/.helper "! f() { echo username=x-access-token; echo password=$TOKEN; };f"
		git push "https://x-access-token:$TOKEN@github.com/$REPO_NAME"
	else
		git push "https://x-access-token:$GITHUB_TOKEN@github.com/$REPO_NAME"
	fi	
else
	echo "☑️ No changes are required to .pot file"
fi
