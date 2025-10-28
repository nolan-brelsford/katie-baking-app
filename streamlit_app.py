import streamlit as st
import subprocess

st.title("🍰 Katie's Baking App")

st.write("An app for helping estimate costs from a recipe.")

TEST = st.text_input(label="Enter your name to say hello from a shell script")

ZIPCODE = st.text_input(label="Enter your zip code")

if TEST:
    st.write(f"You entered: {TEST, ZIPCODE}")
    try:
        # We use subprocess.run to execute the shell script.
        # We pass the user input (TEST) as an argument to the script.
        # capture_output=True captures stdout and stderr.
        # text=True decodes stdout/stderr as text.
        # check=True raises an exception if the script returns a non-zero exit code (an error).
        result = subprocess.run(
            ["./script.sh", TEST, ZIPCODE], capture_output=True, text=True, check=True
        )

        st.write("✅ **Output from `script.sh`:**")
        st.code(result.stdout, language="shell")
    except FileNotFoundError:
        st.error(
            "Error: 'script.sh' not found. Make sure it's in the same directory as streamlit_app.py and is executable (`chmod +x script.sh`)."
        )
    except subprocess.CalledProcessError as e:
        st.error(f"An error occurred while running the shell script:")
        st.code(e.stderr, language="shell")
