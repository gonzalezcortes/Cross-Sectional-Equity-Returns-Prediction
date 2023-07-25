
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
          <ul>
            <li>
            <h3>r2(predicted, actual)</h3>
            <p>This function calculates the coefficient of determination (R^2), which is a statistical measure that represents the proportion of the variance for a dependent variable that's explained by an independent variable in a regression model.</p>
            </li>
            <li>
            <h3>rsq(x, y)</h3>
            <p>This function computes the square of the correlation between the variables x and y.</p>
            </li>
            <li>
            <h3>r2PerYear(predicted_df, actual_df, years)</h3>
            <p>This function calculates the R^2 value for each year given in the 'years' vector. It filters the predicted and actual data frames by year and computes the R^2 value for each year. It then returns a summary of the calculated R^2 values.</p>
            </li>
            <li>
            <h3>monthly_stock_level_prediction_performance(predicted_df, actual_df)</h3>
            <p>This function calculates the square of the correlation between the predicted and actual values for each unique stock in the data frames, and returns a summary of these values.</p>
            </li>
            <li>
            <h3>calculate_cumulative_log_returns(mean_returns)</h3>
            <p>This function calculates the cumulative log returns for a given series of mean returns.</p>
            </li>
            <li>
            <h3>calculate_deciles(labels, returns)</h3>
            <p>This function takes in labels and returns, ranks the returns and divides them into deciles, then returns a data frame with the deciles for each label.</p>
            </li>
            <li>
            <h3>buy_sell(pred_returns)</h3>
            <p>This function calculates deciles of the predicted returns, identifies the top (10th decile) and bottom (1st decile) returns to buy and sell respectively, and returns these as a list of buy and sell holdings for each day.</p>
            </li>
            <li>
            <h3>equally_weighted_portfolio(returns)</h3>
            <p>This function calculates the mean returns for each unique month in the 'returns' data frame and calculates and returns the cumulative log returns for these mean returns.</p>
            </li>
            <li>
            <h3>zero_net_portfolio(actual_returns, predicted_returns)</h3>
            <p>This function calculates an equally-weighted, zero-net portfolio. It does this by determining the holdings to buy based on the top decile of predicted returns for each month, and then computing the mean of the actual returns for these holdings. It then calculates and returns the cumulative log returns for these mean returns.</p>
            </li>
          </ul>
        <li><strong>preProcessing.R</strong> This file contains functions that are used as preprocessing, such as get the data, transform data and return calculation. </li>
        <ul>
            <li>get_data(n_dates, n_char, n_stocks)</li>
              <p> It loads the data from .RData and .csv files, then performs various transformations to reshape and clean the data. Finally, it returns a pivoted data frame grouped by 'Stock' and 'Date'.</p>
            <li>load_transformed_data()</li>
              <p>This function loads the pivoted data (already transformed in get_data()) from a .RData file and returns it as a data frame.</p>
            <li>get_returns(dates, stocks)</li>
              <p>It loads the returns data from a .RData file, and then combines the 'Date', 'Returns', and 'Stock' into a data frame and returns it.</p>
        </ul>
    <li><strong>sampleSplitting.R</strong> Has the functions to get samples and split data in different periods. </li>
      <ul>
        <li>get_samples(df, returns, month_index, training_first, validation_step, testing_step)</li>
          <p> This function takes in six parameters: </p>
            <ul>
              <li>df: The data frame from which the samples will be extracted.</li>
              <li>returns: The data frame containing returns data.</li>
              <li>month_index: The index that specifies the current month.</li>
              <li>training_first: The size of the training set.</li>
              <li>validation_step: The step size for the validation set.</li>
              <li>testing_step: The step size for the testing set.</li>
            </ul>
          <p>The function defines three periods: training, validation, and testing, with their respective start and end points based on the input parameters. It then creates a 'Y' column in the data frame, 'df', corresponding to the 'Returns' from the 'returns' data frame.

Three subsets of the data frame 'df' are created for training, validation, and testing, filtered based on the date ranges defined earlier. These subsets are returned as a list with elements "training", "validation", and "testing" each containing their respective data frames.
          </p>
      </ul>
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