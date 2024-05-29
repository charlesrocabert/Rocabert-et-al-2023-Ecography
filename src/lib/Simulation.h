#ifndef __HMD_model__Simulation__
#define __HMD_model__Simulation__

#include <iostream>
#include <vector>
#include <map>
#include <cmath>
#include <cstring>
#include <stdlib.h>
#include <assert.h>

#include "Enums.h"
#include "Prng.h"
#include "Parameters.h"
#include "Node.h"
#include "Graph.h"


class Simulation
{

public:

  /*----------------------------
   * CONSTRUCTORS
   *----------------------------*/
  Simulation( void ) = delete;
  Simulation( Parameters* parameters );
  Simulation( const Simulation& sim ) = delete;

  /*----------------------------
   * DESTRUCTORS
   *----------------------------*/
  ~Simulation( void );

  /*----------------------------
   * GETTERS
   *----------------------------*/
  inline int    get_iteration( void ) const;
  inline double get_total_log_likelihood( void ) const;
  inline double get_total_log_empty_likelihood( void ) const;
  inline double get_total_log_maximum_likelihood( void ) const;
  inline double get_empty_score( void ) const;
  inline double get_score( void ) const;

  /*----------------------------
   * SETTERS
   *----------------------------*/
  Simulation& operator=(const Simulation&) = delete;

  /*----------------------------
   * PUBLIC METHODS
   *----------------------------*/
  void compute_next_iteration( void );
  void compute_score( void );
  void write_state( std::string filename );
  void write_invasion_euclidean_distributions( std::string observed_filename, std::string simulated_filename );

  /*----------------------------
   * PUBLIC ATTRIBUTES
   *----------------------------*/

protected:

  /*----------------------------
   * PROTECTED METHODS
   *----------------------------*/
  int    draw_number_of_jumps( double human_activity_index );
  double draw_jump_size( void );
  double compute_euclidean_distance( Node* node1, Node* node2 );

  /*----------------------------
   * PROTECTED ATTRIBUTES
   *----------------------------*/

  Parameters* _parameters; /*!< Main parameters   */
  Prng*       _prng;       /*!< Prng              */
  Graph*      _graph;      /*!< Graph structure   */
  int         _iteration;  /*!< Current iteration */

};


/*----------------------------
 * GETTERS
 *----------------------------*/

/**
 * \brief    Get current iteration
 * \details  --
 * \param    void
 * \return   \e int
 */
inline int Simulation::get_iteration( void ) const
{
  return _iteration;
}

/**
 * \brief    Get the total log likelihood
 * \details  --
 * \param    void
 * \return   \e double
 */
inline double Simulation::get_total_log_likelihood( void ) const
{
  return _graph->get_total_log_likelihood();
}

/**
 * \brief    Get the total log likelihood when map is empty
 * \details  --
 * \param    void
 * \return   \e double
 */
inline double Simulation::get_total_log_empty_likelihood( void ) const
{
  return _graph->get_total_log_empty_likelihood();
}

/**
 * \brief    Get the total log maximum likelihood
 * \details  --
 * \param    void
 * \return   \e double
 */
inline double Simulation::get_total_log_maximum_likelihood( void ) const
{
  return _graph->get_total_log_maximum_likelihood();
}

/**
 * \brief    Get the optimization score when map is empty
 * \details  --
 * \param    void
 * \return   \e double
 */
inline double Simulation::get_empty_score( void ) const
{
  return _graph->get_empty_score();
}

/**
 * \brief    Get the optimization score
 * \details  --
 * \param    void
 * \return   \e double
 */
inline double Simulation::get_score( void ) const
{
  return _graph->get_score();
}

/*----------------------------
 * SETTERS
 *----------------------------*/


#endif /* defined(__HMD_model__Simulation__) */
