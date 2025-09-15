
# 🛒 Customer Segmentation with PCA & K-Means (SmartFresh Retail Case)

This project applies **Exploratory Data Analysis (EDA)**, **Principal Component Analysis (PCA)**, and **K-Means Clustering** in **R** to segment retail customers.
It is based on the *SmartFresh Retail Case Study* completed during my MSc Business Analytics at the University of Birmingham.

👉 [Full Report (PDF)](SmartFresh%20Retail%20Case_Final.pdf)

---

## 📊 Project Overview

* **Objective:** Identify customer segments to optimize marketing campaigns and improve retention.
* **Dataset:** Retail customer demographics, spending patterns, and shopping channel usage.
* **Techniques used:**

  * Data cleaning & preprocessing (outlier capping, missing value imputation, feature engineering).
  * Statistical tests: Levene’s test, t-tests for variable selection.
  * Dimensionality reduction: PCA (capturing \~82% variance in 4 components).
  * Segmentation: K-means clustering (optimal k = 3, evaluated by silhouette score).

---

## 🧑‍💻 How to Run the Code

**1. Clone this repository:**

```bash
git clone https://github.com/<your-username>/customer-segmentation-R.git
```

**2. Open R / RStudio** in this project folder.

**3. Install dependencies:**

```r
install.packages(c("tidyverse", "cluster", "factoextra", "plotly", "htmlwidgets", "rgl"))
```

**4. Run the scripts in `scripts/` to reproduce results:**

```r
source("scripts/01_data_cleaning.R")
source("scripts/02_pca_kmeans.R")
```

---

## 📈 Key Results

* **Three clusters identified:**

  1. **High-Income Broad Spenders** → Premium engagement strategy (VIP programs, early access).
  2. **Budget-Conscious Promotion Seekers** → Coupon campaigns, in-store loyalty discounts.
  3. **Selective Online Luxury Shoppers** → Online luxury positioning, influencer marketing, personalized digital offers.

* **Example Plot (Clusters in PCA space):**
  ![](outputs/cluster_plot.png)

👉 For interactive 3D visualizations, see [3D Cluster Plot (HTML)](outputs/3dplot.html).

---

## 🗂 Repository Structure

```
customer-segmentation-R/
│── scripts/               # R scripts for data cleaning, PCA, K-means
│── outputs/               # Figures, cluster results, 3D plots (PNG/HTML/GIF)
│── SmartFresh Retail Case_Final.pdf   # Full academic report
│── README.md              # Project description (this file)
│── .gitignore             # Ignore unnecessary files
│── LICENSE                # License (MIT)
```

---

## 🚀 Skills Demonstrated

* R programming (EDA, PCA, clustering, visualization).
* Data preprocessing (outlier treatment, variable encoding, feature selection).
* Business insight generation from segmentation.
* Reproducible workflow with Git/GitHub.

---

## 📚 References

* Jollife & Cadima (2016) *Principal Component Analysis*.
* Rousseeuw (1987) *Silhouettes for Cluster Validation*.
* Kotler & Keller (2021) *Marketing Management*.

---

## 📜 License

This project is released under the [MIT License](LICENSE).

---

👉 Giờ bạn chỉ cần copy từ dòng **# 🛒 Customer Segmentation...** đến hết, paste vào GitHub, rồi bấm **Commit changes**.

Bạn có muốn mình làm thêm một bản README **ngắn gọn hơn** (tối giản, chỉ có mục tiêu + report PDF + kết quả chính) để bạn dùng khi cần portfolio gọn nhẹ không?

