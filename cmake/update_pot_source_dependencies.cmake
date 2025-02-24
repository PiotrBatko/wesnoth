# Update the source file dependencies of the pot file.
#
# This globs all files cpp in the src directory and looks for the text domain
# definition in that file and outputs these dependencies in POTFILES.in.

# Remove the old input file.
# Dummy target with a non existing (and not created file) is always executed.
add_custom_command(
	OUTPUT ${PROJECT_SOURCE_DIR}/po/${DOMAIN}/POTFILES.in.dummy
	# remove the old file.
	COMMAND ${CMAKE_COMMAND}
			-E remove ${PROJECT_SOURCE_DIR}/po/${DOMAIN}/POTFILES.in
	COMMENT "pot-update [${DOMAIN}]: Removed existing POTFILES.in."
)

# Recreate the input file.
if(DOMAIN STREQUAL ${DEFAULT_DOMAIN})

	# For the default text domain.
	add_custom_command(
		OUTPUT ${PROJECT_SOURCE_DIR}/po/${DOMAIN}/POTFILES.in

		# Find all cpp files which are not in a .git directory, check their
		# textdomain, and write the list of matching files to POTFILES.in.
		COMMAND find src  -name .git -prune -o -name '*.[hc]pp' -print |
				sort |
				while read file\; do
					# If the file doesn't contain a GETTEXT_DOMAIN
					# definition it should be added to the default domain.
					if ! grep '^\#define  *GETTEXT_DOMAIN'
							$$file > /dev/null 2>&1\; then

						echo $$file \;

					# While files don't need a GETTEXT_DOMAIN to be included in
					# the default domain, accept files that contain a
					# GETTEXT_DOMAIN definition for the default domain too.
					elif grep '^\#define  *GETTEXT_DOMAIN  *\"${DOMAIN}\"'
							$$file > /dev/null 2>&1\; then

						echo $$file \;
					fi
				done >|
					${PROJECT_SOURCE_DIR}/po/${DOMAIN}/POTFILES.in


		DEPENDS ${PROJECT_SOURCE_DIR}/po/${DOMAIN}/POTFILES.in.dummy
		WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
		COMMENT
			"pot-update [${DOMAIN}]: Created POTFILES.in for default domain."
	)

else(DOMAIN STREQUAL ${DEFAULT_DOMAIN})

	# For the other text domains.
	add_custom_command(
		OUTPUT ${PROJECT_SOURCE_DIR}/po/${DOMAIN}/POTFILES.in

		# Find all cpp files which are not in a .git directory, check their
		# textdomain, and write the list of matching files to POTFILES.in.
		COMMAND find src  -name .git -prune -o -name '*cpp' -print |
				sort |
				while read file\; do
					# If the file contains a GETTEXT_DOMAIN definition for
					# the current domain add it to the domain.
					if grep '^\#define  *GETTEXT_DOMAIN  *\"${DOMAIN}\"'
							$$file > /dev/null 2>&1\; then

						echo $$file \;
					fi
				done >|
					${PROJECT_SOURCE_DIR}/po/${DOMAIN}/POTFILES.in

		DEPENDS ${PROJECT_SOURCE_DIR}/po/${DOMAIN}/POTFILES.in.dummy
		WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
		COMMENT "pot-update [${DOMAIN}]: Created POTFILES.in."
	)

endif(DOMAIN STREQUAL ${DEFAULT_DOMAIN})
