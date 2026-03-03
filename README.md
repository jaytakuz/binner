# Binner
a cross-platform mobile application developed using the Flutter framework, specifically designed to tackle solid waste management challenges at Chiang Mai University. Inspired by the growing need for smart urban sanitation and circular economy initiatives, the app aims to create a cleaner, well-organized, and more sustainable campus environment.
## Project Overview
Flutter project for **953464 — Mobile App Dev course**
### Group Members
- 652115059	Xiaoyou	Fung
- 662115019	Thippharake	Na Chiengmai
- 662115022	Thanatchanan	Kanjina
- 662115032	Pongpiphat	Kalasuk
- 662115047	Watcharapong	Wanna
# Key Features:
1. **Interactive Bin Locator**: Helps students, staff, and visitors easily find the nearest available trash bins and recycling drop-off points across the CMU campus using an interactive map.
2. **Crowdsourced Mapping**: Empowers the campus community to collectively map new trash bin locations and update bin details so everyone stays up to date on availability.
3. **Waste Separation Guidelines**: Provides comprehensive information on different types of waste (such as general waste, recyclables, compost, and hazardous waste) to encourage proper waste sorting at the source.
4. **User-Friendly Interface**: Developed from the ground up with Flutter, providing a fast, simple, and highly responsive experience for all users.

## Local environment setup

7. **Run with Supabase environment variables**: after adding your `.env` file with `SUPABASE_URL` and `SUPABASE_ANON_KEY`, launch the app locally to verify Supabase connectivity:

```bash
flutter run --dart-define-from-file=.env
```

This ensures that `SupabaseService.initialize()` succeeds and that real-time streams return data correctly before shipping any change.
