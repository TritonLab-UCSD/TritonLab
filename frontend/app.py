"""TritonLab Streamlit app. Week 1 adds the profile form, results, and lab pages."""

import os

import requests
import streamlit as st

API = os.getenv("API_BASE_URL", "http://localhost:8000")

st.set_page_config(page_title="TritonLab", page_icon="🔬")
st.title("TritonLab")
st.caption("Find UCSD research labs that fit you.")

try:
    status = requests.get(f"{API}/health", timeout=3).json().get("status")
    st.success(f"API status: {status}")
except requests.RequestException:
    st.warning("API not reachable. Run `make api` in another terminal.")
