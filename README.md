NAVIIQ — Reverse Navigation App

A SwiftUI multiplatform app for iPhone, iPad, and Mac that helps users discover reachable destinations based on time, budget, and future constraints using NSW Transport data.


Project Overview

Traditional navigation apps require users to enter a destination first.

RouteIQ flips this model by helping users:
- explore where they can go based on **time and budget**
- plan trips with **intermediate stops**
- ensure they still reach a final destination within a **deadline**


Core Features

Explore Mode
Input:
- Start location
- Available time
- Budget

Output:
- Reachable destinations
- Estimated travel time
- Estimated cost
- Basic route summary

Smart Planning Mode
Input:
- Current location
- Final destination
- Must-arrive-by time
- Budget

Output:
- Feasible midpoint destinations such that:
  - Total travel time ≤ deadline
  - Total cost ≤ budget

Tech Stack

- Swift
- SwiftUI
- Xcode
- MVVM Architecture
- NSW Transport API
- GitHub
Location Scope

- Supports **25–30 Sydney locations**
- Includes **core demo locations** and **extended supported locations**


Project Setup

1. Clone the repository

`bash
git clone https://github.com/YOUR-USERNAME/RouteIQ.git
