#ifndef __HMD_model__Graph__
#define __HMD_model__Graph__

#include <iostream>
#include <fstream>
#include <sstream>
#include <cmath>
#include <unordered_map>
#include <cstring>
#include <stdlib.h>
#include <assert.h>

#include "Enums.h"
#include "Prng.h"
#include "Parameters.h"
#include "Node.h"


class Graph
{

public:

  /*----------------------------
   * CONSTRUCTORS
   *----------------------------*/
  Graph( void ) = delete;
  Graph( Parameters* parameters );
  Graph( const Graph& graph ) = delete;

  /*----------------------------
   * DESTRUCTORS
   *----------------------------*/
  ~Graph( void );

  /*----------------------------
   * GETTERS
   *----------------------------*/

  /*--------------------------------------- GRAPH STRUCTURE */

  inline int   get_number_of_nodes( void );
  inline Node* get_node( int identifier );
  inline Node* get_first( void );
  inline Node* get_next( void );

  /*--------------------------------------- MINIMIZATION SCORES */

  inline double get_total_log_likelihood( void ) const;
  inline double get_total_log_empty_likelihood( void ) const;
  inline double get_total_log_maximum_likelihood( void ) const;
  inline double get_empty_score( void ) const;
  inline double get_score( void ) const;

  /*----------------------------
   * SETTERS
   *----------------------------*/
  Graph& operator=(const Graph&) = delete;

  /*----------------------------
   * PUBLIC METHODS
   *----------------------------*/
  void untag( void );
  void update_state( void );
  void compute_score( bool empty );
  void write_state( std::string filename );
  void write_invasion_euclidean_distributions( std::string observed_filename, std::string simulated_filename );

  /*----------------------------
   * PUBLIC ATTRIBUTES
   *----------------------------*/

protected:

  /*----------------------------
   * PROTECTED METHODS
   *----------------------------*/
  int    get_introduction_node_from_coordinates( void );
  void   load_map( void );
  void   load_network( void );
  void   load_sample( void );
  void   compute_statistics( void );
  void   compute_human_activity_index( void );
  void   reset_states( void );
  void   set_introduction_node( void );
  double compute_euclidean_distance( Node* node1, Node* node2 );

  /*----------------------------
   * PROTECTED ATTRIBUTES
   *----------------------------*/

  /*--------------------------------------- MAIN PARAMETERS */

  Parameters* _parameters; /*!< Main parameters */

  /*--------------------------------------- GRAPH STRUCTURE */

  std::unordered_map<int, Node*>           _map; /*!< Nodes map          */
  std::unordered_map<int, Node*>::iterator _it;  /*!< Nodes map iterator */

  /*--------------------------------------- GRAPH STATISTICS */

  int    _introduction_node;       /*!< Introduction node            */
  double _min_x_coord;             /*!< Minimum X coordinate         */
  double _mean_x_coord;            /*!< Mean X coordinate            */
  double _max_x_coord;             /*!< Maximum X coordinate         */
  double _min_y_coord;             /*!< Minimum Y coordinate         */
  double _mean_y_coord;            /*!< Mean Y coordinate            */
  double _max_y_coord;             /*!< Maximum Y coordinate         */
  double _min_weights_sum;         /*!< Minimum weights sum in nodes */
  double _mean_weights_sum;        /*!< Mean weights sum in nodes    */
  double _max_weights_sum;         /*!< Maximum weights sum in nodes */
  double _min_population;          /*!< Minimum population size      */
  double _mean_population;         /*!< Mean population size         */
  double _max_population;          /*!< Maximum population size      */
  double _min_population_density;  /*!< Minimum population density   */
  double _mean_population_density; /*!< Mean population density      */
  double _max_population_density;  /*!< Maximum population density   */
  double _min_road_density;        /*!< Minimum population size      */
  double _mean_road_density;       /*!< Mean population size         */
  double _max_road_density;        /*!< Maximum population size      */

  /*--------------------------------------- MINIMIZATION SCORE */

  double _total_log_likelihood;         /*!< Total log hypergeometric likelihood         */
  double _total_log_empty_likelihood;   /*!< Total log empty hypergeometric likelihood   */
  double _total_log_maximum_likelihood; /*!< Total log maximum hypergeometric likelihood */
  double _empty_score;                  /*!< Optimization score with empty map           */
  double _score;                        /*!< Optimization score                          */

};


/*----------------------------
 * GETTERS
 *----------------------------*/

/*--------------------------------------- GRAPH STRUCTURE */

/**
 * \brief    Get total number of nodes
 * \details  --
 * \param    void
 * \return   \e int
 */
inline int Graph::get_number_of_nodes( void )
{
  return (int)_map.size();
}

/**
 * \brief    Get node
 * \details  --
 * \param    int identifier
 * \return   \e Node*
 */
inline Node* Graph::get_node( int identifier )
{
  if (_map.find(identifier) != _map.end())
  {
    return _map[identifier];
  }
  return NULL;
}

/**
 * \brief    Get first node
 * \details  --
 * \param    void
 * \return   \e Node*
 */
inline Node* Graph::get_first( void )
{
  _it = _map.begin();
  return _it->second;
}

/**
 * \brief    Get next node
 * \details  --
 * \param    void
 * \return   \e Node*
 */
inline Node* Graph::get_next( void )
{
  ++_it;
  if (_it == _map.end())
  {
    return NULL;
  }
  return _it->second;
}

/*--------------------------------------- MINIMIZATION SCORES */

/**
 * \brief    Get the total log likelihood
 * \details  --
 * \param    void
 * \return   \e double
 */
inline double Graph::get_total_log_likelihood( void ) const
{
  return _total_log_likelihood;
}

/**
 * \brief    Get the total log empty likelihood
 * \details  --
 * \param    void
 * \return   \e double
 */
inline double Graph::get_total_log_empty_likelihood( void ) const
{
  return _total_log_empty_likelihood;
}

/**
 * \brief    Get the total log maximum likelihood
 * \details  --
 * \param    void
 * \return   \e double
 */
inline double Graph::get_total_log_maximum_likelihood( void ) const
{
  return _total_log_maximum_likelihood;
}

/**
 * \brief    Get the optimization score with empty map
 * \details  --
 * \param    void
 * \return   \e double
 */
inline double Graph::get_empty_score( void ) const
{
  return _empty_score;
}

/**
 * \brief    Get the optimization score
 * \details  --
 * \param    void
 * \return   \e double
 */
inline double Graph::get_score( void ) const
{
  return _score;
}

/*----------------------------
 * SETTERS
 *----------------------------*/


#endif /* defined(__HMD_model__Graph__) */
