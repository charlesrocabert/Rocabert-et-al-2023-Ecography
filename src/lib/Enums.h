#ifndef __HMD_model__Enums__
#define __HMD_model__Enums__


/**
 * \brief   Type of experimental data
 * \details --
 */
enum type_of_data
{
  PRESENCE_ONLY    = 0, /*!< Presence-only data    */
  PRESENCE_ABSENCE = 1  /*!< Presence-absence data */
};

/**
 * \brief   Jump distribution law
 * \details --
 */
enum jump_distribution_law
{
  DIRAC      = 0, /*!< Dirac law      */
  NORMAL     = 1, /*!< Normal law     */
  LOG_NORMAL = 2, /*!< Log-normal law */
  CAUCHY     = 3  /*!< Cauchy law     */
};

/**
 * \brief   Optimization function
 * \details --
 */
enum optimization_function
{
  LSS            = 0, /*!< Least-square-sum score            */
  LOG_LIKELIHOOD = 1, /*!< Log likelihood score              */
  LIKELIHOOD_LSS = 2  /*!< Likelihood least-square-sum score */
};


#endif /* defined(__HMD_model__Enums__) */
