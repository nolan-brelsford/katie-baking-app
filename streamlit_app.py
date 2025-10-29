import streamlit as st
import subprocess

st.title("🍰 Katie's Baking App")

st.write("An app for helping estimate costs from a recipe.")

PRODUCT_TERM = st.text_input(label="Enter a product to search for (e.g., milk)")

ZIPCODE = st.text_input(label="Enter your zip code")

if PRODUCT_TERM and ZIPCODE:
    with st.spinner(f"Searching for '{PRODUCT_TERM}' in zip code {ZIPCODE}..."):
        try:
            # 1. Access the secret from st.secrets
            # Note: streamlit community cloud secrets uses lower case for variable names
            kroger_credentials = st.secrets["kroger"]["client_credentials"]

            # We use subprocess.run to execute the shell script.
            # 2. Pass the user input and the secret as arguments to the script.
            # capture_output=True captures stdout and stderr.
            # text=True decodes stdout/stderr as text.
            # check=True raises an exception if the script returns a non-zero exit code (an error).
            result = subprocess.run(
                ["./script.sh", PRODUCT_TERM, ZIPCODE, kroger_credentials],
                capture_output=True,
                text=True,
                check=True,
            )

            st.write("✅ **Output from `script.sh`:**")
            st.json(result.stdout)
        except FileNotFoundError:
            st.error(
                "Error: 'script.sh' not found. Make sure it's in the same directory as streamlit_app.py and is executable (`chmod +x script.sh`)."
            )
        except subprocess.CalledProcessError as e:
            st.error(f"An error occurred while running the shell script:")
            st.code(e.stderr, language="shell")
