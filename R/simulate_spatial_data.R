#' A simple spatial simulation function
#' Create n points on a unit square and simulate a z value based
#' on a polynomial function of x and y.
#' @param n Number of points to simulate
#' @return A data frame with columns x, y, and z
#' @export
simulate_spatial_data <- function(n = 100) {
  # Simulate n random (x, y) points in the unit square [0,1] x [0,1]
  # create a random id
  points <- data.frame(
    id = 1:n,
    x = runif(n, min = 0, max = 1),
    y = runif(n, min = 0, max = 1)
  )

  # Define polynomial coefficients
  beta <- c(
    beta0 = 1,
    beta1 = 2,
    beta2 = -1.5,
    beta3 = 0.5,
    beta4 = 0.75,
    beta5 = -1
  )

  # Simulate z using a 3D polynomial of x and y + random noise
  points$z <- with(
    points,
    beta["beta0"] +
      beta["beta1"] * x +
      beta["beta2"] * y +
      beta["beta3"] * x^2 +
      beta["beta4"] * y^2 +
      beta["beta5"] * x * y +
      rnorm(n, sd = 0.2) # Gaussian noise
  )
  return(points)
}
