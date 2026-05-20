# ─────────────────────────────────────────────
# IMPORTING THE NECESSARY LIBRARIES
# ─────────────────────────────────────────────

import streamlit as st
import pandas as pd
import numpy as np
import plotly.graph_objects as go
import plotly.express as px
from plotly.subplots import make_subplots
import warnings
warnings.filterwarnings("ignore")

# ─────────────────────────────────────────────
# PAGE CONFIG
# ─────────────────────────────────────────────
st.set_page_config(
    page_title="Global Climate Events Economic Impact Dashboard",
    layout="wide",
    initial_sidebar_state="collapsed"
)

# ─────────────────────────────────────────────
# CUSTOM CSS
# ─────────────────────────────────────────────
st.markdown("""
<style>
@import url('https://fonts.googleapis.com/css2?family=Rajdhani:wght@500;600;700&family=Inter:wght@300;400;500&display=swap');

html, body, [class*="css"] {
    font-family: 'Inter', sans-serif;
}

/* Dark background */
.stApp {
    background: #0a0e1a;
    color: #e2e8f0;
}

/* Hide default Streamlit menu/footer */
#MainMenu, footer { visibility: hidden; }

/* Header */
.dashboard-title {
    font-family: 'Rajdhani', sans-serif;
    font-size: 2.1rem;
    font-weight: 700;
    color: #f0f4ff;
    letter-spacing: 2px;
    text-transform: uppercase;
    margin-bottom: 0px;
}
.dashboard-subtitle {
    font-size: 0.8rem;
    color: #64748b;
    letter-spacing: 3px;
    text-transform: uppercase;
    margin-bottom: 12px;
}

/* KPI cards */
div[data-testid="metric-container"] {
    background: linear-gradient(135deg, #111827 0%, #1e293b 100%);
    border: 1px solid #1e3a5f;
    border-radius: 10px;
    padding: 14px 18px;
    box-shadow: 0 4px 20px rgba(0,0,0,0.4);
}
div[data-testid="metric-container"] label {
    color: #94a3b8 !important;
    font-size: 0.7rem !important;
    letter-spacing: 1.5px !important;
    text-transform: uppercase !important;
}
div[data-testid="metric-container"] div[data-testid="stMetricValue"] {
    color: #38bdf8 !important;
    font-family: 'Rajdhani', sans-serif !important;
    font-size: 1.7rem !important;
    font-weight: 700 !important;
}

/* Nav buttons */
.stButton > button {
    background: #111827;
    color: #94a3b8;
    border: 1px solid #1e3a5f;
    border-radius: 8px;
    font-size: 0.72rem;
    font-weight: 500;
    letter-spacing: 0.5px;
    padding: 8px 12px;
    transition: all 0.2s ease;
    width: 100%;
    white-space: nowrap;
}
.stButton > button:hover {
    background: #1e3a5f;
    color: #38bdf8;
    border-color: #38bdf8;
}
.stButton > button:active {
    background: linear-gradient(135deg, #0f3460 0%, #0d2a4a 100%) !important;
    color: #7dd3fc !important;
    border-color: #7dd3fc !important;
    box-shadow: 0 0 18px rgba(56,189,248,0.45), inset 0 2px 6px rgba(0,0,0,0.5) !important;
    transform: scale(0.97);
}

/* Active nav button */
.active-nav > button {
    background: linear-gradient(135deg, #0f3460 0%, #1e3a5f 100%) !important;
    color: #38bdf8 !important;
    border-color: #38bdf8 !important;
    box-shadow: 0 0 12px rgba(56,189,248,0.25);
}

/* Filter bar */
.filter-bar {
    background: #111827;
    border: 1px solid #1e293b;
    border-radius: 10px;
    padding: 10px 16px;
    margin-bottom: 12px;
}

/* Chart containers */
div[data-testid="stImage"] {
    border-radius: 8px;
    overflow: hidden;
}

/* Page indicator */
.page-indicator {
    font-family: 'Rajdhani', sans-serif;
    font-size: 0.85rem;
    color: #38bdf8;
    letter-spacing: 2px;
    text-transform: uppercase;
    margin-bottom: 6px;
}

/* Divider */
.h-divider {
    border-top: 1px solid #1e293b;
    margin: 8px 0;
}

/* Selectbox / slider dark styling */
.stSelectbox > div > div,
.stMultiSelect > div > div {
    background: #111827 !important;
    border-color: #1e3a5f !important;
    color: #e2e8f0 !important;
}
</style>
""", unsafe_allow_html=True)

# ─────────────────────────────────────────────
# LOAD DATA
# ─────────────────────────────────────────────
@st.cache_data
def load_data():
    df = pd.read_csv("global_climate_cleaned_data.csv", encoding="utf-8-sig")
    df.columns = df.columns.str.strip()
    df["date"] = pd.to_datetime(df["date"], errors="coerce")
    df["year"] = df["year"].astype(int)
    df["is_weekend"] = df["is_weekend"].astype(str).str.strip().str.lower().map({"true": True, "false": False}).fillna(False)
    df["aid_required"] = df["aid_required"].astype(str).str.strip().str.lower().map({"true": True, "false": False}).fillna(False)
    return df

df_raw = load_data()

# ─────────────────────────────────────────────
# CHART CATEGORIES (5 pages × 5 charts)
# ─────────────────────────────────────────────
CATEGORIES = {
    "📅 Temporal Patterns":    [4, 2, 8, 1, 3],
    "🌍 Geographic Impact":    [23, 13, 11, 10, 5],
    "💀 Human Toll":           [9, 15, 16, 19, 22],
    "⚡ Response & Aid":       [6, 18, 12, 17, 7],
    "🔬 Strategic Analytics":  [24, 25, 21, 14, 20],
}
CAT_NAMES = list(CATEGORIES.keys())

# ─────────────────────────────────────────────
# SESSION STATE
# ─────────────────────────────────────────────
if "page_idx" not in st.session_state:
    st.session_state.page_idx = 0

# ─────────────────────────────────────────────
# PLOTLY DARK THEME DEFAULTS
# ─────────────────────────────────────────────
CHART_BG   = "#0f172a"
PANEL_BG   = "#111827"
GRID_COLOR = "#1e293b"
TEXT_COLOR = "#94a3b8"
ACCENT     = "#38bdf8"
ACCENT2    = "#f472b6"
ACCENT3    = "#34d399"

PLOTLY_LAYOUT = dict(
    paper_bgcolor=CHART_BG,
    plot_bgcolor=PANEL_BG,
    font=dict(color=TEXT_COLOR, size=11),
    title_font=dict(color="#cbd5e1", size=13, family="Inter"),
    margin=dict(l=50, r=20, t=45, b=40),
    xaxis=dict(gridcolor=GRID_COLOR, zerolinecolor=GRID_COLOR, tickfont=dict(size=10)),
    yaxis=dict(gridcolor=GRID_COLOR, zerolinecolor=GRID_COLOR, tickfont=dict(size=10)),
    legend=dict(bgcolor=PANEL_BG, bordercolor=GRID_COLOR, borderwidth=1, font=dict(size=10)),
    hoverlabel=dict(bgcolor="#1e293b", bordercolor=ACCENT, font=dict(color="#f0f4ff", size=11)),
)

CHART_HEIGHT = 340

# ─────────────────────────────────────────────
# DASHBOARD THEME
# ─────────────────────────────────────────────
TAB10 = px.colors.qualitative.Plotly
SET2  = px.colors.qualitative.Pastel
SET1  = px.colors.qualitative.Bold


def _base_layout(**overrides):
    """Return a copy of the shared layout dict with optional overrides."""
    layout = dict(PLOTLY_LAYOUT)
    layout.update(overrides)
    return layout


# ─────────────────────────────────────────────
# HEADER
# ─────────────────────────────────────────────
st.markdown('<div class="dashboard-title">Global Climate Events - Economic Impact Dashboard </div>', unsafe_allow_html=True)
st.markdown('<div class="dashboard-subtitle">Data Analyst Specialist Track — Final Project</div>', unsafe_allow_html=True)

# ─────────────────────────────────────────────
# LOGOS
# ─────────────────────────────────────────────
import base64

def img_to_b64(path):
    with open(path, "rb") as f:
        return base64.b64encode(f.read()).decode()

logo_project = img_to_b64("Project_logo.png")
logo_yat     = img_to_b64("YAT_logo.png")
logo_depi    = img_to_b64("DEPI_logo.png")

st.markdown(f"""
<div style="
    display: flex;
    align-items: center;
    justify-content: flex-end;
    gap: 28px;
    margin-top: -80px;
    margin-bottom: 8px;
    padding-right: 8px;
">
    <img src="data:image/png;base64,{logo_project}"
         style="height:110px; width:auto; object-fit:contain;" />
    <img src="data:image/png;base64,{logo_yat}"
         style="height:100px; width:auto; object-fit:contain;" />
    <img src="data:image/png;base64,{logo_depi}"
         style="height:130px; width:auto; object-fit:contain;" />
</div>
""", unsafe_allow_html=True)

# ─────────────────────────────────────────────
# GLOBAL FILTERS
# ─────────────────────────────────────────────
with st.container():
    fc1, fc2, fc3, fc4, fc5 = st.columns([2, 2, 2, 2, 1])
    with fc1:
        year_min, year_max = int(df_raw["year"].min()), int(df_raw["year"].max())
        year_range = st.slider("📆 Year Range", year_min, year_max, (year_min, year_max), label_visibility="collapsed")
    with fc2:
        continents = ["All Continents"] + sorted(df_raw["continent"].dropna().unique().tolist())
        sel_continent = st.selectbox("🌍 Continent", continents, label_visibility="collapsed")
    with fc3:
        event_types = df_raw["event_type"].dropna().unique().tolist()
        sel_events = st.multiselect("⚡ Event Types", sorted(event_types), placeholder="All Event Types", label_visibility="collapsed")
    with fc4:
        severity_cats = ["All Severities"] + df_raw["severity_category"].dropna().unique().tolist()
        sel_severity = st.selectbox("🔥 Severity", severity_cats, label_visibility="collapsed")
    with fc5:
        seasons = ["All Seasons"] + df_raw["season"].dropna().unique().tolist()
        sel_season = st.selectbox("🍂 Season", seasons, label_visibility="collapsed")

# Apply filters
df = df_raw[df_raw["year"].between(year_range[0], year_range[1])]
if sel_continent != "All Continents":
    df = df[df["continent"] == sel_continent]
if sel_events:
    df = df[df["event_type"].isin(sel_events)]
if sel_severity != "All Severities":
    df = df[df["severity_category"] == sel_severity]
if sel_season != "All Seasons":
    df = df[df["season"] == sel_season]

st.markdown('<div class="h-divider"></div>', unsafe_allow_html=True)

# ─────────────────────────────────────────────
# KPI CARDS
# ─────────────────────────────────────────────
k1, k2, k3, k4, k5, k6 = st.columns(6)
total_events  = len(df)
total_deaths  = int(df["deaths"].sum())
econ_impact   = df["economic_impact_million_usd"].sum()
avg_severity  = df["severity"].mean() if len(df) else 0
avg_response  = df["response_time_hours"].mean() if len(df) else 0
pct_aid       = (df["international_aid_million_usd"] > 0).mean() * 100 if len(df) else 0

k1.metric("🌪️ Total Events",        f"{total_events:,}")
k2.metric("💀 Total Deaths",         f"{total_deaths:,}")
k3.metric("💰 Economic Impact",      f"${econ_impact/1000:,.1f}B")
k4.metric("⚡ Avg Severity (/10)",   f"{avg_severity:.0f}")
k5.metric("⏱️ Avg Response Time",    f"{avg_response:.0f} hrs")
k6.metric("🤝 Events with Aid",      f"{pct_aid:.1f}%")

st.markdown('<div class="h-divider"></div>', unsafe_allow_html=True)

# ─────────────────────────────────────────────
# PAGE NAVIGATION BUTTONS
# ─────────────────────────────────────────────
nav_cols = st.columns(5)
for i, cat in enumerate(CAT_NAMES):
    with nav_cols[i]:
        is_active = (st.session_state.page_idx == i)
        if is_active:
            st.markdown('<div class="active-nav">', unsafe_allow_html=True)
        if st.button(cat, key=f"nav_{i}"):
            st.session_state.page_idx = i
            st.rerun()
        if is_active:
            st.markdown('</div>', unsafe_allow_html=True)

current_cat = CAT_NAMES[st.session_state.page_idx]
chart_ids   = CATEGORIES[current_cat]
page_num    = st.session_state.page_idx + 1

st.markdown(f'<div class="page-indicator">◈ {current_cat} &nbsp;·&nbsp; Page {page_num} of 5</div>', unsafe_allow_html=True)
st.markdown('<div class="h-divider"></div>', unsafe_allow_html=True)

# ─────────────────────────────────────────────
# CHART RENDER HELPER
# ─────────────────────────────────────────────
def no_data_chart(title="No Data Available"):
    fig = go.Figure()
    fig.add_annotation(
        text=f"⚠️ {title}<br>Adjust filters to see data",
        xref="paper", yref="paper", x=0.5, y=0.5,
        showarrow=False, font=dict(color=TEXT_COLOR, size=12),
    )
    fig.update_layout(**_base_layout(title="", height=CHART_HEIGHT))
    return fig


# ─────────────────────────────────────────────
# ALL 25 CHART FUNCTIONS
# ─────────────────────────────────────────────

def chart_1(df):
    """1. Yearly Trend: Event Frequency vs Economic Loss"""
    grp = df.groupby("year").agg(count=("event_id", "count"), econ=("economic_impact_million_usd", "sum")).reset_index()
    if grp.empty: return no_data_chart("Chart 1")
    fig = make_subplots(specs=[[{"secondary_y": True}]])
    fig.add_trace(go.Bar(
        x=grp["year"], y=grp["count"], name="# Events",
        marker_color=ACCENT, opacity=0.65,
        hovertemplate="Year: %{x}<br>Events: %{y:,}<extra></extra>",
    ), secondary_y=False)
    fig.add_trace(go.Scatter(
        x=grp["year"], y=grp["econ"], name="Econ Loss ($M)",
        mode="lines+markers", line=dict(color=ACCENT2, width=2),
        marker=dict(size=6),
        hovertemplate="Year: %{x}<br>Econ Loss: $%{y:,.0f}M<extra></extra>",
    ), secondary_y=True)
    layout = _base_layout(title="Yearly Trend: Event Frequency vs Economic Loss", height=CHART_HEIGHT)
    layout["yaxis"]  = dict(title="Event Count",        gridcolor=GRID_COLOR, tickfont=dict(color=ACCENT))
    layout["yaxis2"] = dict(title="Economic Loss ($M)", gridcolor=GRID_COLOR, tickfont=dict(color=ACCENT2),
                            overlaying="y", side="right")
    fig.update_layout(**layout)
    return fig


def chart_2(df):
    """2. Chronological Monthly Distribution of Fatalities"""
    month_order = ["January","February","March","April","May","June",
                   "July","August","September","October","November","December"]
    grp = df.groupby("month_name")["deaths"].sum().reindex(month_order, fill_value=0)
    if grp.empty: return no_data_chart("Chart 2")
    colors = px.colors.sample_colorscale("Plasma", [i / max(len(grp)-1, 1) for i in range(len(grp))])
    fig = go.Figure(go.Bar(
        x=[m[:3] for m in month_order], y=grp.values,
        marker_color=colors,
        hovertemplate="Month: %{x}<br>Deaths: %{y:,}<extra></extra>",
    ))
    fig.update_layout(**_base_layout(title="Monthly Distribution of Fatalities",
                                     yaxis_title="Total Deaths", height=CHART_HEIGHT))
    return fig


def chart_3(df):
    """3. Top 10 Event Types Distributed Across Seasons"""
    top10 = df["event_type"].value_counts().head(10).index.tolist()
    sub = df[df["event_type"].isin(top10)]
    if sub.empty: return no_data_chart("Chart 3")
    pivot = sub.groupby(["event_type", "season"]).size().unstack(fill_value=0)
    season_order = [s for s in ["Spring", "Summer", "Autumn", "Winter"] if s in pivot.columns]
    pivot = pivot[season_order] if season_order else pivot
    fig = go.Figure()
    for i, season in enumerate(pivot.columns):
        fig.add_trace(go.Bar(
            name=season, x=pivot.index, y=pivot[season],
            marker_color=SET2[i % len(SET2)],
            hovertemplate=f"Season: {season}<br>Event: %{{x}}<br>Count: %{{y:,}}<extra></extra>",
        ))
    fig.update_layout(**_base_layout(title="Top 10 Event Types × Season",
                                     barmode="group", yaxis_title="Event Count",
                                     xaxis_tickangle=-35, height=CHART_HEIGHT))
    return fig


def chart_4(df):
    """4. Disaster Occurrence Share by Season"""
    grp = df["season"].value_counts()
    if grp.empty: return no_data_chart("Chart 4")
    fig = go.Figure(go.Pie(
        labels=grp.index, values=grp.values,
        hole=0.0,
        marker=dict(colors=px.colors.qualitative.Safe,
                    line=dict(color=CHART_BG, width=2)),
        textfont=dict(color="#f0f4ff", size=11),
        hovertemplate="Season: %{label}<br>Events: %{value:,}<br>Share: %{percent}<extra></extra>",
    ))
    fig.update_layout(**_base_layout(title="Disaster Occurrence Share by Season", height=CHART_HEIGHT))
    return fig


def chart_5(df):
    """5. Yearly Economic Impact Evolution by Continent"""
    grp = df.groupby(["year", "continent"])["economic_impact_million_usd"].sum().reset_index()
    if grp.empty: return no_data_chart("Chart 5")
    fig = go.Figure()
    for i, cont in enumerate(grp["continent"].unique()):
        sub = grp[grp["continent"] == cont]
        fig.add_trace(go.Scatter(
            x=sub["year"], y=sub["economic_impact_million_usd"],
            mode="lines+markers", name=cont,
            line=dict(color=TAB10[i % len(TAB10)], width=2),
            marker=dict(size=5),
            hovertemplate=f"{cont}<br>Year: %{{x}}<br>Impact: $%{{y:,.0f}}M<extra></extra>",
        ))
    fig.update_layout(**_base_layout(title="Yearly Economic Impact by Continent",
                                     yaxis_title="Economic Impact ($M)", height=CHART_HEIGHT))
    return fig


def chart_6(df):
    """6. Disaster Family Average Severity Heatmap by Continent"""
    pivot = df.pivot_table(values="severity", index="continent", columns="event_family", aggfunc="mean")
    if pivot.empty: return no_data_chart("Chart 6")
    fig = go.Figure(go.Heatmap(
        z=pivot.values, x=pivot.columns.tolist(), y=pivot.index.tolist(),
        colorscale="YlOrRd",
        text=np.round(pivot.values, 1),
        texttemplate="%{text}",
        textfont=dict(size=9),
        hovertemplate="Continent: %{y}<br>Family: %{x}<br>Avg Severity: %{z:.2f}<extra></extra>",
    ))
    fig.update_layout(**_base_layout(title="Avg Severity: Disaster Family × Continent", height=CHART_HEIGHT))
    return fig


def chart_7(df):
    """7. Average Response Time vs Event Volume by Severity Category"""
    grp = df.groupby("severity_category").agg(
        avg_rt=("response_time_hours", "mean"),
        count=("event_id", "count")
    ).reset_index()
    if grp.empty: return no_data_chart("Chart 7")
    order = ["Low", "Medium", "High", "Severe"]
    grp["severity_category"] = pd.Categorical(grp["severity_category"], categories=order, ordered=True)
    grp = grp.sort_values("severity_category")
    seq = px.colors.sample_colorscale("YlOrRd", [i / max(len(grp)-1, 1) for i in range(len(grp))])
    fig = go.Figure(go.Scatter(
        x=grp["avg_rt"], y=grp["count"],
        mode="markers+text",
        text=grp["severity_category"],
        textposition="top right",
        textfont=dict(color=TEXT_COLOR, size=10),
        marker=dict(
            size=grp["count"] / grp["count"].max() * 40 + 10,
            color=seq, opacity=0.85,
            line=dict(color=CHART_BG, width=1)
        ),
        hovertemplate="Severity: %{text}<br>Avg Response: %{x:.1f} hrs<br>Volume: %{y:,}<extra></extra>",
    ))
    fig.update_layout(**_base_layout(title="Avg Response Time vs Event Volume by Severity",
                                     xaxis_title="Avg Response Time (hrs)",
                                     yaxis_title="Event Volume", height=CHART_HEIGHT))
    return fig


def chart_8(df):
    """8. Top Seasonal Disasters by Average Economic Impact"""
    grp = df.groupby(["season", "event_type"])["economic_impact_million_usd"].mean().reset_index()
    top = grp.sort_values("economic_impact_million_usd", ascending=False).groupby("season").head(1)
    if top.empty: return no_data_chart("Chart 8")
    top = top.sort_values("economic_impact_million_usd")
    labels = top["season"] + " (" + top["event_type"] + ")"
    fig = go.Figure(go.Bar(
        x=top["economic_impact_million_usd"], y=labels,
        orientation="h",
        marker_color=SET2[:len(top)],
        hovertemplate="Season/Type: %{y}<br>Avg Impact: $%{x:.2f}M<extra></extra>",
    ))
    fig.update_layout(**_base_layout(title="Top Seasonal Disasters by Avg Economic Impact",
                                     xaxis_title="Avg Economic Impact ($M)", height=CHART_HEIGHT))
    return fig


def chart_9(df):
    """9. Top 10 Most Dangerous Disaster Types (By Total Deaths)"""
    grp = df.groupby("event_type")["deaths"].sum().nlargest(10).sort_values()
    if grp.empty: return no_data_chart("Chart 9")
    colors = px.colors.sample_colorscale("Plasma_r", [i / max(len(grp)-1, 1) for i in range(len(grp))])
    fig = go.Figure(go.Bar(
        x=grp.values, y=grp.index, orientation="h",
        marker_color=colors,
        hovertemplate="Type: %{y}<br>Deaths: %{x:,}<extra></extra>",
    ))
    fig.update_layout(**_base_layout(title="Top 10 Deadliest Disaster Types",
                                     xaxis_title="Total Deaths", height=CHART_HEIGHT))
    return fig


def chart_10(df):
    """10. Deadliest Event Types Broken Down by Continent"""
    top5_types = df.groupby("event_type")["deaths"].sum().nlargest(5).index.tolist()
    sub = df[df["event_type"].isin(top5_types)]
    if sub.empty: return no_data_chart("Chart 10")
    pivot = sub.groupby(["continent", "event_type"])["deaths"].sum().unstack(fill_value=0)
    fig = go.Figure()
    for i, etype in enumerate(pivot.columns):
        fig.add_trace(go.Bar(
            name=etype, x=pivot.index, y=pivot[etype],
            marker_color=SET1[i % len(SET1)],
            hovertemplate=f"{etype}<br>Continent: %{{x}}<br>Deaths: %{{y:,}}<extra></extra>",
        ))
    fig.update_layout(**_base_layout(title="Deadliest Disaster Types by Continent",
                                     barmode="group", yaxis_title="Total Deaths",
                                     xaxis_tickangle=-30, height=CHART_HEIGHT))
    return fig


def chart_11(df):
    """11. Top 10 Most Financially Impacted Countries Worldwide"""
    grp = df.groupby("country")["economic_impact_million_usd"].sum().nlargest(10).sort_values()
    if grp.empty: return no_data_chart("Chart 11")
    colors = px.colors.sample_colorscale("Blues_r", [i / max(len(grp)-1, 1) for i in range(len(grp))])
    fig = go.Figure(go.Bar(
        x=grp.values, y=grp.index, orientation="h",
        marker_color=colors,
        hovertemplate="Country: %{y}<br>Impact: $%{x:,.0f}M<extra></extra>",
    ))
    fig.update_layout(**_base_layout(title="Top 10 Most Financially Impacted Countries",
                                     xaxis_title="Total Economic Impact ($M)", height=CHART_HEIGHT))
    return fig


def chart_12(df):
    """12. Average Emergency Response Time by Event Type"""
    grp = df.groupby("event_type")["response_time_hours"].mean().sort_values(ascending=False)
    if grp.empty: return no_data_chart("Chart 12")
    colors = px.colors.sample_colorscale("YlOrRd_r", [i / max(len(grp)-1, 1) for i in range(len(grp))])
    fig = go.Figure(go.Bar(
        x=grp.values, y=grp.index, orientation="h",
        marker_color=colors,
        hovertemplate="Type: %{y}<br>Avg Response: %{x:.1f} hrs<extra></extra>",
    ))
    fig.add_vline(x=grp.mean(), line_dash="dash", line_color=ACCENT,
                  annotation_text=f"Mean: {grp.mean():.1f}h",
                  annotation_font_color=ACCENT, annotation_font_size=10)
    fig.update_layout(**_base_layout(title="Avg Emergency Response Time by Event Type",
                                     xaxis_title="Avg Response Time (hrs)", height=CHART_HEIGHT))
    return fig


def chart_13(df):
    """13. Average Disaster Severity by Continent and Season"""
    pivot = df.pivot_table(values="severity", index="continent", columns="season", aggfunc="mean")
    if pivot.empty: return no_data_chart("Chart 13")
    fig = go.Figure(go.Heatmap(
        z=pivot.values, x=pivot.columns.tolist(), y=pivot.index.tolist(),
        colorscale="Plasma",
        text=np.round(pivot.values, 1),
        texttemplate="%{text}",
        textfont=dict(size=9),
        hovertemplate="Continent: %{y}<br>Season: %{x}<br>Avg Severity: %{z:.2f}<extra></extra>",
    ))
    fig.update_layout(**_base_layout(title="Avg Disaster Severity: Continent × Season", height=CHART_HEIGHT))
    return fig


def chart_14(df):
    """14. Impact Correlation: How Response Speed Mitigates Loss"""
    sub = df[["response_time_hours", "economic_impact_million_usd", "severity"]].dropna()
    if sub.empty: return no_data_chart("Chart 14")
    z = np.polyfit(sub["response_time_hours"], sub["economic_impact_million_usd"], 1)
    p = np.poly1d(z)
    xs = np.linspace(sub["response_time_hours"].min(), sub["response_time_hours"].max(), 100)
    fig = go.Figure()
    fig.add_trace(go.Scatter(
        x=sub["response_time_hours"], y=sub["economic_impact_million_usd"],
        mode="markers",
        marker=dict(
            color=sub["severity"], colorscale="YlOrRd", opacity=0.4, size=5,
            colorbar=dict(
                title="Severity",
                tickfont=dict(color=TEXT_COLOR, size=9),
                title_font=dict(color=TEXT_COLOR, size=10),
                x=1.08,          # push colorbar further right
                xanchor="left",
                len=0.75,        # slightly shorter so it clears the legend
                y=0.35,          # anchor it lower, away from the legend
                yanchor="middle",
            ),
            line=dict(width=0)
        ),
        hovertemplate="Response: %{x:.1f} hrs<br>Impact: $%{y:.1f}M<br>Severity: %{marker.color:.1f}<extra></extra>",
        name="Events",
    ))
    fig.add_trace(go.Scatter(
        x=xs, y=p(xs), mode="lines",
        line=dict(color=ACCENT2, width=2, dash="dash"),
        name="Trend", hoverinfo="skip",
    ))
    layout = _base_layout(
        title="Response Speed vs Economic Loss",
        xaxis_title="Response Time (hrs)",
        yaxis_title="Economic Impact ($M)",
        height=CHART_HEIGHT
    )
    layout.update(
        legend=dict(
            orientation="h",      # horizontal row
            x=0.5, y=1.08,        # centered just above the plot area
            xanchor="center", yanchor="bottom",
            bgcolor=PANEL_BG,
            bordercolor=GRID_COLOR,
            borderwidth=1,
            font=dict(color=TEXT_COLOR, size=11),
        )
    )
    fig.update_layout(**layout)
    return fig


def chart_15(df):
    """15. Top 5 Deadliest Individual Events Recorded Each Year"""
    top5 = df.groupby("year").apply(lambda x: x.nlargest(5, "deaths")).reset_index(drop=True)
    grp = top5.groupby("year")["deaths"].sum().reset_index()
    if grp.empty: return no_data_chart("Chart 15")
    colors = px.colors.sample_colorscale("Plasma", [i / max(len(grp)-1, 1) for i in range(len(grp))])
    fig = go.Figure(go.Bar(
        x=grp["year"].astype(str), y=grp["deaths"],
        marker_color=colors,
        hovertemplate="Year: %{x}<br>Deaths: %{y:,}<extra></extra>",
    ))
    fig.update_layout(**_base_layout(title="Top 5 Deadliest Events per Year (Cumulative)",
                                     yaxis_title="Total Deaths (Top 5 Events)", height=CHART_HEIGHT))
    return fig


def chart_16(df):
    """16. Aid Impact Twin Chart: Deaths & Economic Loss"""
    aid_yes = df[df["international_aid_million_usd"] > 0]
    aid_no  = df[df["international_aid_million_usd"] == 0]
    cats = ["With Aid", "Without Aid"]
    deaths_vals = [aid_yes["deaths"].mean(), aid_no["deaths"].mean()]
    econ_vals   = [aid_yes["economic_impact_million_usd"].mean(), aid_no["economic_impact_million_usd"].mean()]

    fig = make_subplots(rows=1, cols=2, subplot_titles=("Avg Deaths", "Avg Economic Loss"))
    fig.add_trace(go.Bar(
        x=cats, y=deaths_vals, marker_color=[ACCENT, ACCENT2],
        hovertemplate="%{x}<br>Avg Deaths: %{y:.1f}<extra></extra>", showlegend=False,
    ), row=1, col=1)
    fig.add_trace(go.Bar(
        x=cats, y=econ_vals, marker_color=[ACCENT, ACCENT2],
        hovertemplate="%{x}<br>Avg Impact: $%{y:.2f}M<extra></extra>", showlegend=False,
    ), row=1, col=2)
    layout = _base_layout(title="Aid Impact: Deaths & Economic Loss", height=CHART_HEIGHT)
    layout["yaxis"]  = dict(title="Avg Deaths",      gridcolor=GRID_COLOR)
    layout["yaxis2"] = dict(title="Avg Impact ($M)", gridcolor=GRID_COLOR)
    fig.update_layout(**layout)
    fig.update_annotations(font=dict(color="#cbd5e1", size=11))
    return fig


def chart_17(df):
    """17. Response Efficiency Index by Continent"""
    grp = df.groupby("continent")["response_efficiency"].mean().sort_values()
    if grp.empty: return no_data_chart("Chart 17")
    colors = px.colors.sample_colorscale("RdYlGn", [i / max(len(grp)-1, 1) for i in range(len(grp))])
    fig = go.Figure(go.Bar(
        x=grp.values, y=grp.index, orientation="h",
        marker_color=colors,
        hovertemplate="Continent: %{y}<br>Efficiency Index: %{x:.2f}<extra></extra>",
    ))
    fig.update_layout(**_base_layout(title="Response Efficiency Index by Continent",
                                     xaxis_title="Avg Response Efficiency Index (lower = faster)",
                                     height=CHART_HEIGHT))
    return fig


def chart_18(df):
    """18. Top 10 Countries by Average Aid-to-Loss Ratio"""
    grp = df[df["economic_impact_million_usd"] > 0].groupby("country")["aid_to_loss_ratio"].mean()
    grp = grp.replace([np.inf, -np.inf], np.nan).dropna().nlargest(10).sort_values()
    if grp.empty: return no_data_chart("Chart 18")
    colors = px.colors.sample_colorscale("ice", [i / max(len(grp)-1, 1) for i in range(len(grp))])
    fig = go.Figure(go.Bar(
        x=grp.values, y=grp.index, orientation="h",
        marker_color=colors,
        hovertemplate="Country: %{y}<br>Aid-to-Loss Ratio: %{x:.2f}x<extra></extra>",
    ))
    fig.update_layout(**_base_layout(title="Top 10 Countries: Aid-to-Loss Ratio",
                                     xaxis_title="Avg Aid-to-Loss Ratio", height=CHART_HEIGHT))
    return fig


def chart_19(df):
    """19. Disaster Family Lethality Rate"""
    grp = df.groupby("event_family").agg(deaths=("deaths", "sum"), casualties=("total_casualties", "sum")).reset_index()
    grp["lethality_pct"] = (grp["deaths"] / grp["casualties"].replace(0, np.nan)) * 100
    grp = grp.dropna(subset=["lethality_pct"]).sort_values("lethality_pct", ascending=False)
    if grp.empty: return no_data_chart("Chart 19")
    colors = px.colors.sample_colorscale("Reds_r", [i / max(len(grp)-1, 1) for i in range(len(grp))])
    fig = go.Figure(go.Bar(
        x=grp["event_family"], y=grp["lethality_pct"],
        marker_color=colors,
        hovertemplate="Family: %{x}<br>Lethality Rate: %{y:.1f}%<extra></extra>",
    ))
    fig.update_layout(**_base_layout(title="Disaster Family Lethality Rate (Deaths / Total Casualties)",
                                     yaxis_title="Lethality Rate (%)",
                                     xaxis_tickangle=-30, height=CHART_HEIGHT))
    return fig


def chart_20(df):
    """20. Strategic Matrix: Aid Coverage vs Response Efficiency"""
    grp = df.groupby("continent").agg(
        avg_aid=("aid_percentage", "mean"),
        avg_eff=("response_efficiency", "mean"),
        total=("event_id", "count")
    ).reset_index()
    if grp.empty: return no_data_chart("Chart 20")

    fig = go.Figure()

    # One trace per continent so each gets its own legend entry
    for i, row in grp.iterrows():
        fig.add_trace(go.Scatter(
            x=[row["avg_eff"]],
            y=[row["avg_aid"]],
            mode="markers",
            name=row["continent"],
            marker=dict(
                size=row["total"] / grp["total"].max() * 30 + 8,
                color=TAB10[i % len(TAB10)],
                opacity=0.85,
                line=dict(color=CHART_BG, width=1)
            ),
            hovertemplate=(
                f"<b>{row['continent']}</b><br>"
                "Avg Efficiency: %{x:.2f}<br>"
                "Avg Aid: %{y:.1f}%"
                "<extra></extra>"
            ),
        ))

    fig.add_hline(y=grp["avg_aid"].mean(), line_dash="dash", line_color=ACCENT, line_width=1, opacity=0.6)
    fig.add_vline(x=grp["avg_eff"].mean(), line_dash="dash", line_color=ACCENT2, line_width=1, opacity=0.6)

    layout = _base_layout(
        title="Strategic Matrix: Aid Coverage vs Response Efficiency",
        xaxis_title="Avg Response Efficiency",
        yaxis_title="Avg Aid Coverage (%)",
        height=CHART_HEIGHT
    )
    layout.update(
        showlegend=True,
        legend=dict(
            x=1.02, y=1,
            xanchor="left", yanchor="top",
            bgcolor=PANEL_BG,
            bordercolor=GRID_COLOR,
            borderwidth=1,
            font=dict(color=TEXT_COLOR, size=11),
        )
    )
    fig.update_layout(**layout)
    return fig


def chart_21(df):
    """21. Climate Resilience Index: Top 10 Most Prepared Countries"""
    grp = df.groupby("country").agg(
        avg_rt=("response_time_hours", "mean"),
        avg_eff=("response_efficiency", "mean"),
        avg_infra=("infrastructure_damage_score", "mean"),
        count=("event_id", "count")
    ).reset_index()
    grp = grp[grp["count"] >= 5]
    if grp.empty: return no_data_chart("Chart 21")
    # Resilience = low response time + high efficiency + low damage
    rt_norm  = 1 - (grp["avg_rt"]    - grp["avg_rt"].min())    / (grp["avg_rt"].max()    - grp["avg_rt"].min()    + 1e-9)
    eff_norm =     (grp["avg_eff"]   - grp["avg_eff"].min())   / (grp["avg_eff"].max()   - grp["avg_eff"].min()   + 1e-9)
    inf_norm = 1 - (grp["avg_infra"] - grp["avg_infra"].min()) / (grp["avg_infra"].max() - grp["avg_infra"].min() + 1e-9)
    grp["resilience"] = (rt_norm + eff_norm + inf_norm) / 3 * 100
    top10 = grp.nlargest(10, "resilience").sort_values("resilience")
    colors = px.colors.sample_colorscale("YlGn", [i / max(len(top10)-1, 1) for i in range(len(top10))])
    fig = go.Figure(go.Bar(
        x=top10["resilience"], y=top10["country"], orientation="h",
        marker_color=colors,
        hovertemplate="Country: %{y}<br>Resilience Index: %{x:.1f}<extra></extra>",
    ))
    fig.update_layout(**_base_layout(title="Climate Resilience Index: Top 10 Countries",
                                     xaxis_title="Resilience Index (0–100)", height=CHART_HEIGHT))
    return fig


def chart_22(df):
    """22. Catastrophic Profiling: Deaths by Extreme Events Only"""
    extreme = df[df["severity"] >= 7]
    if extreme.empty: return no_data_chart("Chart 22: No extreme events in selection")
    grp = extreme.groupby("event_type")["deaths"].sum().nlargest(10).sort_values(ascending=False)
    colors = px.colors.sample_colorscale("Magma_r", [i / max(len(grp)-1, 1) for i in range(len(grp))])
    fig = go.Figure(go.Bar(
        x=grp.index, y=grp.values,
        marker_color=colors,
        hovertemplate="Type: %{x}<br>Deaths: %{y:,}<extra></extra>",
    ))
    fig.update_layout(**_base_layout(title="Catastrophic Events (Severity ≥7): Deaths by Type",
                                     yaxis_title="Total Deaths",
                                     xaxis_tickangle=-35, height=CHART_HEIGHT))
    return fig


def chart_23(df):
    """23. Geographical Funding Gap: Avg Aid for High-Severity Events"""
    high_sev = df[df["severity"] > 6]
    grp = high_sev.groupby("continent")["international_aid_million_usd"].mean().sort_values(ascending=False)
    if grp.empty: return no_data_chart("Chart 23")
    colors = px.colors.sample_colorscale("Blues_r", [i / max(len(grp)-1, 1) for i in range(len(grp))])
    fig = go.Figure(go.Bar(
        x=grp.index, y=grp.values,
        marker_color=colors,
        hovertemplate="Continent: %{x}<br>Avg Aid: $%{y:.3f}M<extra></extra>",
    ))
    fig.update_layout(**_base_layout(title="Funding Gap: Avg Aid for High-Severity Events (>6)",
                                     yaxis_title="Avg Aid Disbursed ($M)",
                                     xaxis_tickangle=-30, height=CHART_HEIGHT))
    return fig


def chart_24(df):
    """24. Top 5 Historic Timeline Peaks (Worst Cumulative Monthly Pressures)"""
    df2 = df.copy()
    if "month_name" not in df2.columns:
        month_map = {1:"January",2:"February",3:"March",4:"April",5:"May",6:"June",
                     7:"July",8:"August",9:"September",10:"October",11:"November",12:"December"}
        df2["month_name"] = df2["month"].map(month_map)

    grp = df2.groupby(["year", "month_name", "month"]).agg(
        cumulative_impact_million_USD=("economic_impact_million_usd", "sum")
    ).reset_index()

    timeline_peaks = grp.nlargest(5, "cumulative_impact_million_USD").copy()
    timeline_peaks = timeline_peaks.sort_values("cumulative_impact_million_USD", ascending=True)
    timeline_peaks["period"] = timeline_peaks["year"].astype(str) + " - " + timeline_peaks["month_name"]

    if timeline_peaks.empty: return no_data_chart("Chart 24")

    colors = px.colors.sample_colorscale(
        "Inferno", [i / max(len(timeline_peaks) - 1, 1) for i in range(len(timeline_peaks))]
    )

    fig = go.Figure(go.Bar(
        x=timeline_peaks["cumulative_impact_million_USD"],
        y=timeline_peaks["period"],
        orientation="h",
        marker_color=colors,
        hovertemplate="<b>%{y}</b><br>Cumulative Impact: $%{x:,.1f}M<extra></extra>",
    ))

    fig.update_layout(**_base_layout(
        title="Top 5 Historic Timeline Peaks",
        xaxis_title="Cumulative Economic Impact ($ Millions)",
        yaxis_title="Timeline Period",
        height=CHART_HEIGHT
    ))
    return fig


def chart_25(df):
    """25. Diagnostic: Response Time – Weekdays vs Weekends"""
    df2 = df.copy()
    df2["day_type"] = df2["is_weekend"].map({True: "Weekend", False: "Weekday"})
    if df2.empty: return no_data_chart("Chart 25")
    grp = df2.groupby(["day_type", "event_type"])["response_time_hours"].mean().reset_index()
    pivot = grp.pivot(index="event_type", columns="day_type", values="response_time_hours").dropna()
    if pivot.empty or "Weekday" not in pivot.columns or "Weekend" not in pivot.columns:
        grp2 = df2.groupby("day_type")["response_time_hours"].mean()
        fig = go.Figure(go.Bar(
            x=grp2.index, y=grp2.values,
            marker_color=[ACCENT, ACCENT2],
            hovertemplate="%{x}<br>Avg Response: %{y:.1f} hrs<extra></extra>",
        ))
        fig.update_layout(**_base_layout(title="Response Time: Weekdays vs Weekends",
                                         yaxis_title="Avg Response Time (hrs)", height=CHART_HEIGHT))
        return fig
    pivot = pivot.sort_values("Weekday")
    fig = go.Figure()
    fig.add_trace(go.Bar(
        name="Weekday", x=pivot.index, y=pivot["Weekday"],
        marker_color=ACCENT, opacity=0.85,
        hovertemplate="Type: %{x}<br>Weekday: %{y:.1f} hrs<extra></extra>",
    ))
    fig.add_trace(go.Bar(
        name="Weekend", x=pivot.index, y=pivot["Weekend"],
        marker_color=ACCENT2, opacity=0.85,
        hovertemplate="Type: %{x}<br>Weekend: %{y:.1f} hrs<extra></extra>",
    ))
    fig.update_layout(**_base_layout(title="Response Time by Event Type: Weekdays vs Weekends",
                                     barmode="group", yaxis_title="Avg Response Time (hrs)",
                                     xaxis_tickangle=-35, height=CHART_HEIGHT))
    return fig


# ─────────────────────────────────────────────
# CHART REGISTRY
# ─────────────────────────────────────────────
CHART_FNS = {
    1: chart_1,  2: chart_2,  3: chart_3,  4: chart_4,  5: chart_5,
    6: chart_6,  7: chart_7,  8: chart_8,  9: chart_9,  10: chart_10,
    11: chart_11, 12: chart_12, 13: chart_13, 14: chart_14, 15: chart_15,
    16: chart_16, 17: chart_17, 18: chart_18, 19: chart_19, 20: chart_20,
    21: chart_21, 22: chart_22, 23: chart_23, 24: chart_24, 25: chart_25,
}

# ─────────────────────────────────────────────
# RENDER CURRENT PAGE (2 rows × 3 cols, then 1 row × 2 cols)
# – but we have 5 charts, use 2+3 or 3+2 layout
# ─────────────────────────────────────────────
ids = CATEGORIES[current_cat]  # list of 5 chart IDs

row1 = st.columns(3)
row2 = st.columns(2)

for col_idx, chart_id in enumerate(ids[:3]):
    with row1[col_idx]:
        try:
            fig = CHART_FNS[chart_id](df)
            st.plotly_chart(fig, use_container_width=True, config={"displayModeBar": True, "modeBarButtonsToRemove": ["zoom2d","pan2d","select2d","lasso2d","zoomIn2d","zoomOut2d","autoScale2d","resetScale2d","hoverClosestCartesian","hoverCompareCartesian","toggleSpikelines","toImage"], "modeBarButtonsToAdd": ["fullscreen"], "displaylogo": False})
        except Exception as e:
            st.plotly_chart(no_data_chart(f"Chart {chart_id} Error"), use_container_width=True,
                            config={"displayModeBar": False})

for col_idx, chart_id in enumerate(ids[3:]):
    with row2[col_idx]:
        try:
            fig = CHART_FNS[chart_id](df)
            st.plotly_chart(fig, use_container_width=True, config={"displayModeBar": True, "modeBarButtonsToRemove": ["zoom2d","pan2d","select2d","lasso2d","zoomIn2d","zoomOut2d","autoScale2d","resetScale2d","hoverClosestCartesian","hoverCompareCartesian","toggleSpikelines","toImage"], "modeBarButtonsToAdd": ["fullscreen"], "displaylogo": False})
        except Exception as e:
            st.plotly_chart(no_data_chart(f"Chart {chart_id} Error"), use_container_width=True,
                            config={"displayModeBar": False})

# ─────────────────────────────────────────────
# FOOTER
# ─────────────────────────────────────────────
st.markdown('<div class="h-divider"></div>', unsafe_allow_html=True)
st.markdown(
    '<div style="text-align:center;color:#334155;font-size:0.7rem;letter-spacing:1.5px;">'
    'GLOBAL CLIMATE EVENTS - ECONOMIC IMAPCT DASHBOARD · POWERED BY STREAMLIT · ALL CREDITS GOES TO AHMED BAHAA</div>',
    unsafe_allow_html=True
)
