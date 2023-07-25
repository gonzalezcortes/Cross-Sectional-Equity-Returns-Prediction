
<h1>Machine Learning for Cross-Sectional Equity Returns Prediction</h1>
<p>This repository contains the R code related to the research on applying Machine Learning (ML) techniques for predicting cross-sectional equity returns using factors. This research aims to explore the potential of ML algorithms for enhancing the performance of factor-based investment strategies.</p>

<h2>Contents</h2>
<p>The repository includes the following folders:</p>
<ul>

  <li><strong> trainingGeneratedData.R </strong> Contains the training of ML models using generated data. </li>

  <li><strong> trainingRealData.R </strong> This file contains the code to open and process the data and train the ML models. Once the training is finished, the data is saved into a 'CSV' file. </li>
  
  <li><strong> portfolio.R </strong> Once the training is finished, the 'CSV' files can be opened in this file to create a portfolio and plot it.

  <li><strong>src:</strong> Contains the source code for various utility functions and modules used in the analysis. </li>
      <ul>
        <li><strong>auxiliares.R</strong> Contains auxiliary functions such as plotting and others.</li>
        <li><strong>dataGeneration.R</strong> This file generates data following the framework for data generation of Gu et al. (2020). </li>
        <li><strong>metrics.R</strong> Holds multiple metrics functions such as R-square, Cumulative log returns and others. </li>
        <li><strong>preProcessing.R</strong> This file contains functions that are used as preprocessing, such as get the data, transform data and return calculation. </li>
        <ul>
            <li>get_data(n_dates, n_char, n_stocks)</li>
              <p> It loads the data from .RData and .csv files, then performs various transformations to reshape and clean the data. Finally, it returns a pivoted data frame grouped by 'Stock' and 'Date'.</p>
            <li>load_transformed_data()</li>
              <p>This function loads the pivoted data from a .RData file and returns it as a data frame.</p>
            <li>get_returns(dates, stocks)</li>
              <p>It loads the returns data from a .RData file, and then combines the 'Date', 'Returns', and 'Stock' into a data frame and returns it.</p>
        </ul>
    <li><strong>sampleSplitting.R</strong> Has the functions to get samples and split data in different periods. </li>
    <li><strong>trainingModels.R</strong> Contains different ML models. </li>
  </ul>
</ul>


<h2>Contact</h2>
<p>If you have any questions or issues with the code in this repository, please feel free to contact me at d.gonzalezcortes@opendeusto.es or at daniel-alejandro.gonzalez-cortes.20@neoma-bs.com</p>

<h3> Relevant Bibliography </h3>
	<blockquote>
		[1] Gu, S., Kelly, B., & Xiu, D. (2020). Empirical asset pricing via machine learning. The Review of Financial Studies, 33(5), 2223-2273.
	</blockquote>
	<blockquote>
		[2] De Nard, G., Hediger, S., & Leippold, M. (2022). Subsampled factor models for asset pricing: The rise of Vasa. Journal of Forecasting, 41(6), 1217-1247. 
	</blockquote>
<h3> Data Sources </h3>
<p> The data is not attached in this repository, however can be found in the following link:</p>
<p>https://dachxiu.chicagobooth.edu/download/datashare.zip</p>
<h3> Additional Data Sources </h3>
<p>https://github.com/xiubooth/ML_Codes<p>

<a href="https://oup.silverchair-cdn.com/oup/backfile/Content_public/Journal/rfs/33/5/10.1093_rfs_hhaa009/4/hhaa009_supplementary_data.pdf?Expires=1690990748&Signature=3dT1q3ttrmAXOvMe0aeYw~quN7~fL7P6yVXY4xSqH1ylKFEnNyZNuliveNI0XXPlP2YMbl8vt~Glpt4F0NcQKSlOw9upHhCxHIUkFQ3XI0zoxCB20rIEmRp-G0P2QqeGSTghLAZ0QEQSeyLGikIZUrvnDpq-gZ97nabWRGn9RGWb3ARSL1~7~~bMF2kJej~g0tQbgXT~-77VZvnoMgkhDnH~6et3tFiLYcffnHJY2l2oMHAfgccHDa6Hzg8smjTXVA5Qsopnfu7dADViyRsX2hOcXWjBMs1gc4TceAxoYgTMNLsTzPbULpmM2llFbUsIrS0En05XjjaJKeluMW~yMw__&Key-Pair-Id=APKAIE5G5CRDK6RD3PGA"> Internet Appendix (Monte Carlo simulations) from the paper Empirical Asset Pricing via Machine Learning